import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/challenges/do_challenge/do_memorization_challenge/memorization_challenge_step_done_callback.dart';
import 'package:flutter/material.dart';

class ChoicesWidget extends StatelessWidget {
  final List<Choice> choices;
  final MemorizationChallengeStepDoneCallback onCorrectChoiceSelected;
  final ScrollController scrollController;

  ChoicesWidget({
    this.choices,
    this.onCorrectChoiceSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    choices.shuffle();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: choices.length,
      controller: scrollController,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8,
            bottom: 4,
          ),
          child: RawMaterialButton(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                choices[index].word,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            fillColor: Theme.of(context).colorScheme.primary,
            elevation: 2,
            onPressed: () {
              if (choices[index].correct) {
                SnackBarUtils.showSnackBar(
                  context,
                  'اختيار صحيح',
                  color: Colors.green.shade400,
                );
                onCorrectChoiceSelected.call();
              } else {
                SnackBarUtils.showSnackBar(
                  context,
                  'اختيار خاطئ، حاول مرة أخرى',
                );
              }
            },
          ),
        );
      },
    );
  }
}

class Choice {
  final String word;
  final bool correct;

  Choice({
    @required this.word,
    this.correct,
  });
}
