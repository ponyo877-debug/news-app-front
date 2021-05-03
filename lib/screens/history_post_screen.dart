import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'news_state.dart';
import 'news_card.dart';


// https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc
class HistoryPostScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () async {
            context.read(historyProvider.notifier).initHistory();
          },
          child: Consumer(builder: (context, watch, _) {
                final list = watch(historyProvider);
                Widget childWidget;
                if (list.length == 0) {
                  childWidget = Center(child: CircularProgressIndicator());
                } else {
                  print("%%%%%%%%%%");
                  childWidget = ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: list.length == null ? 0 : list.length,
                    itemBuilder: (BuildContext context, int index) {
                      var rindex = list.length - index - 1;
                      return NewsHistoryCard(
                        "${list[rindex].id}", // "_id" is not available, so use "id"
                        "${list[rindex].image}",
                        "${list[rindex].publishedAt}",
                        "${list[rindex].siteID}",
                        "${list[rindex].sitetitle}",
                        "${list[rindex].titles}",
                        "${list[rindex].url}",
                        false,
                      );
                    },
                  );
                }
                return childWidget;
              })),
    );
  }

}
