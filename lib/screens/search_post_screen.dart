import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'news_card.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/history_model.dart';

class SearchPostScreen extends StatefulWidget {
  @override
  _SearchPostScreen createState() => _SearchPostScreen();
}

class _SearchPostScreen extends State<SearchPostScreen> {
  TextEditingController _searchController = TextEditingController();

  Map<String, dynamic> data;
  String baseURL = "http://gitouhon-juku-k8s2.ga";
  List newsPost = [];

  Box historyBox;
  Box favoriteBox;
  Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = null;
    searchResultsList();
  }

  _onSearchChanged() {
    _future = null;
    searchResultsList();
  }

  Future searchResultsList() async {
    String searchwords = _searchController.text;
    var getPostURL = baseURL + "/elastic/get?words=" + searchwords;
    print(getPostURL);
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);
    if (mounted) {
      setState(() {
        newsPost = data["data"];
        if (newsPost != null) {
          _future = _initReadFlg();
        }
      });
    }
  }

  Future _initReadFlg() async {
    //if (historyBox == null) {
    historyBox = await Hive.openBox<HistoryModel>('history');
    favoriteBox = await Hive.openBox<HistoryModel>('favorite');
    //}
    for (int i = 0; i < newsPost.length; i++) {
      if (newsPost[i]["readFlg"] == null) {
        var check = historyBox.values.firstWhere(
            (list) => list.id == newsPost[i]["_id"],
            orElse: () => null);
        if (check == null) {
          newsPost[i]["readFlg"] = false;
        } else {
          newsPost[i]["readFlg"] = true;
        }
      }

      //init favorite Flg
      if (newsPost[i]["favoriteFlg"] != true) {
        var check = favoriteBox.values.firstWhere(
                (list) => list.id == newsPost[i]["_id"],
            orElse: () => null);
        if (check == null) {
          newsPost[i]["favoriteFlg"] = false;
        } else {
          newsPost[i]["favoriteFlg"] = true;
        }
      }
    }
    return true;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
              ),
            ),
            Expanded(
                child: FutureBuilder(
                    future: _future,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      Widget childWidget;
                      if (newsPost == null) {
                        childWidget = Container();
                      } else if (!snapshot.hasData) {
                        childWidget =
                            Center(child: CircularProgressIndicator());
                      } else {
                        childWidget = ListView.builder(
                          // physics: AlwaysScrollableScrollPhysics(),
                          itemCount: newsPost == null ? 0 : newsPost.length,
                          itemBuilder: (BuildContext context, int index) {
                            return NewsCard(
                              "${newsPost[index]["_id"] == "" ? newsPost[index]["id"] : newsPost[index]["_id"]}",
                              "${newsPost[index]["image"]}",
                              "${newsPost[index]["publishedAt"]}",
                              "${newsPost[index]["siteID"]}",
                              "${newsPost[index]["sitetitle"]}",
                              "${newsPost[index]["titles"]}",
                              "${newsPost[index]["url"]}",
                              newsPost[index]["readFlg"],
                              newsPost[index]["favoriteFlg"],
                            );
                          },
                        );
                      }
                      return childWidget;
                    })),
          ],
        ),
      ),
    );
  }
}
