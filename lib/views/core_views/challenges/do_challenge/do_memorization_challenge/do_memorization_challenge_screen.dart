import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/group.dart';
import 'package:azkar/models/memorization_challenge.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/challenges/all_challenges/challenge_list_item_widget.dart';
import 'package:azkar/views/core_views/challenges/do_challenge/do_challenge_utils.dart';
import 'package:azkar/views/core_views/challenges/do_challenge/do_memorization_challenge/do_memorization_challenge_list_item_widget.dart';
import 'package:azkar/views/core_views/challenges/do_challenge/friends_progress_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoMemorizationChallengeScreen extends StatefulWidget {
  final MemorizationChallenge challenge;
  final ChallengeChangedCallback challengeChangedCallback;
  final Group group;

  // Note that some of the challenged users may not be friends.
  final List<String> challengedUsersIds;
  final List<String> challengedUsersFullNames;

  final List<Friend> friendshipScores;

  DoMemorizationChallengeScreen({
    @required this.challenge,
    @required this.group,
    @required this.challengedUsersIds,
    @required this.challengedUsersFullNames,
    @required this.challengeChangedCallback,
    @required this.friendshipScores,
  });

  @override
  _DoMemorizationChallengeScreenState createState() =>
      _DoMemorizationChallengeScreenState();
}

class _DoMemorizationChallengeScreenState
    extends State<DoMemorizationChallengeScreen>
    with SingleTickerProviderStateMixin {
  ConfettiController confettiControler;
  bool _finishedConfetti;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _finishedConfetti = false;
    confettiControler =
        ConfettiController(duration: const Duration(seconds: 1));
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            widget.challenge.getName(),
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Card(
                    child: Visibility(
                      visible: widget.group != null,
                      child: widget.group == null
                          ? Container()
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 5,
                              ),
                              child: FriendsProgressWidget(
                                challenge: Challenge(
                                    memorizationChallenge: widget.challenge),
                                challengedUsersIds: widget.challengedUsersIds,
                                challengedUsersFullNames:
                                    widget.challengedUsersFullNames,
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      controller: _scrollController,
                      separatorBuilder: (BuildContext context, int index) =>
                          Padding(padding: EdgeInsets.only(bottom: 4)),
                      shrinkWrap: true,
                      itemCount: widget.challenge.questions.length,
                      itemBuilder: (context, index) {
                        return DoMemorizationChallengeListItemWidget(
                          key: UniqueKey(),
                          question: widget.challenge.questions[index],
                          challenge: widget.challenge,
                          scrollController: _scrollController,
                          onQuestionDoneCallback: () async {
                            setState(() {
                              widget.challenge.questions[index].finished = true;
                            });

                            try {
                              await ServiceProvider.challengesService
                                  .finishMemorizationChallengeQuestion(
                                      widget.challenge.id, index);
                            } on ApiException catch (e) {
                              SnackBarUtils.showSnackBar(
                                  context, e.errorStatus.errorMessage);
                              return;
                            }

                            if (widget.challenge.done()) {
                              confettiControler.addListener(() {
                                if (confettiControler.state ==
                                    ConfettiControllerState.stopped) {
                                  onFinishedConfetti();
                                }
                              });

                              confettiControler.play();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            getConfettiWidget(),
          ],
        ));
  }

  Align getConfettiWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        maximumSize: Size(30, 30),
        shouldLoop: false,
        confettiController: confettiControler,
        blastDirection: pi,
        blastDirectionality: BlastDirectionality.explosive,
        maxBlastForce: 10,
        minBlastForce: 3,
        emissionFrequency: 0.5,
        numberOfParticles: 5,
        gravity: 1,
      ),
    );
  }

  onFinishedConfetti() async {
    // Avoid popping twice if confetti's controller decided to call our listner
    // more than once.
    if (_finishedConfetti) {
      return;
    }
    _finishedConfetti = true;

    bool ratingRequestShown = false;
    if (Platform.isAndroid && widget.challengedUsersIds.length >= 2) {
      var prefs = await ServiceProvider.cacheManager.getPrefs();
      if (!prefs.containsKey(CacheManager.CACHE_KEY_ASKED_FOR_REVIEW)) {
        prefs.setBool(CacheManager.CACHE_KEY_ASKED_FOR_REVIEW, true);
        ratingRequestShown = true;
        await DoChallengeUtils.showReviewDialog(context);
      }
    }

    if (!ratingRequestShown) {
      await DoChallengeUtils.showFriendsScoreDialog(
          context, widget.friendshipScores, widget.challengedUsersIds);
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    confettiControler.dispose();
    super.dispose();
  }
}
