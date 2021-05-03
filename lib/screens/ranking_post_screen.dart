import 'package:flutter/material.dart';
import 'news_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'news_state.dart';

class RankingPostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async {
        context.read(rankingProvider.notifier).getRanking();
      },
      child: Consumer(builder: (context, watch, _) {
        final list = watch(rankingProvider);
        Widget childWidget;
        if (list.length == 0) {
          childWidget = Center(child: CircularProgressIndicator());
        } else {
          childWidget = ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: list == null ? 0 : list.length,
            itemBuilder: (BuildContext context, int index) {
              // "${index + 1}",
              return NewsRankingCard(
                "${list[index]["_id"] == "" ? list[index]["id"] : list[index]["_id"]}",
                "${index + 1}",
                "${list[index]["publishedAt"]}",
                "${list[index]["siteID"]}",
                "${list[index]["sitetitle"]}",
                "${list[index]["titles"]}",
                "${list[index]["url"]}",
                list[index]["readFlg"],
              );
            },
          );
        }
        return childWidget;
      }),
    ));
  }

}
