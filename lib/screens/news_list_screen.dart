import 'package:flutter/material.dart';
import 'post_screen.dart';
import 'ranking_post_screen.dart';
import 'search_post_screen.dart';
import 'history_post_screen.dart';
import 'setting_screen.dart';
import 'comment_screen.dart';
import 'user_conf_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
// TODO: Need to implement follow import
import 'comment/comment_model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabInfo {
  IconData icon;
  String title;
  Widget widget;
  TabInfo(this.icon, this.title, this.widget);
}

class NewsListScreen extends StatelessWidget {
  //with TickerProviderStateMixin {
  //TabController _tabController;

  //final Map<String, dynamic> data;

  final List<TabInfo> _tabs = [
    TabInfo(Icons.format_list_numbered, 'Ranking', RankingPostScreen()),
    TabInfo(Icons.search, 'Search', SearchPostScreen()),
    TabInfo(Icons.home, 'Home', PostScreen()),
    TabInfo(Icons.person_pin , 'My Page', HistoryPostScreen()),
    TabInfo(Icons.settings, 'Setting', SettingScreen()),
    TabInfo(Icons.bolt, 'Com', CommentScreen(user: currentUser)),
    TabInfo(Icons.supervised_user_circle, 'User', UserConfScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    // getNameData();
    return DefaultTabController(
      length: 7,
      initialIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("😁まとめくん😁"),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: ConvexAppBar(
            style: TabStyle.reactCircle,
            backgroundColor: Colors.blueGrey,
            color: Colors.white,
            //activeColor: Colors.blue,
            items: <TabItem>[
              for (final entry in _tabs)
                TabItem(icon: entry.icon, title: entry.title),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: _tabs.map((tab) => tab.widget).toList(),
          ),
        ),
        // TODO: Need to implement hidden AppBar
        // body: SafeArea(
        //   child: extended.NestedScrollView(
        //     headerSliverBuilder:
        //     (BuildContext context, bool innerBoxIsScrolled) {
        //       return <Widget>[
        //         SliverOverlapAbsorber(
        //           handle:
        //           extended.NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        //           sliver: SliverAppBar(
        //             title: const Center(child: Text("😁まとめくん😁")),
        //             pinned: false,
        //             forceElevated: innerBoxIsScrolled,
        //           ),
        //         ),
        //       ];
        //     },
        //     body: TabBarView(
        //       children: _tabs.map((tab) => tab.widget).toList(),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  initNameData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("Name", "まとめくん");
  }

  getNameData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var myStringData = await prefs.getString("Name");
    print("Name: " + myStringData);
    if (myStringData == null) {
      initNameData();
    }
  }
}
