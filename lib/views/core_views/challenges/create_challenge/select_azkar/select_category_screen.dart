import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/category.dart';
import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/views/core_views/challenges/create_challenge/select_azkar/select_azkar_screen.dart';
import 'package:flutter/material.dart';

class SelectCategoryScreen extends StatelessWidget {
  final List<Category> categories;

  SelectCategoryScreen({@required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.of(context).selectAzkarCategory,
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: categories.length,
              // Cache everything
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            categories[index].name,
                            style: TextStyle(
                              fontSize: 30,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTapDown: (_) async {
                    List<SubChallenge> selectedSubChallenges =
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectAzkarScreen(
                                      azkar: categories[index].azkar,
                                    ))) as List<SubChallenge>;
                    if ((selectedSubChallenges?.length ?? 0) != 0) {
                      Navigator.pop(context, selectedSubChallenges);
                    }
                  },
                );
              }),
        ),
      ),
    );
  }
}
