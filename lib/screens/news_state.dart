import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'models/history_model.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newsProvider = StateNotifierProvider((ref) => NewsState("latest"));
final recommendedProvider = StateNotifierProvider((ref) => NewsState("recommended"));
final historyProvider = StateNotifierProvider((ref) => NewsState("history"));
final favoriteProvider = StateNotifierProvider((ref) => NewsState("favorite"));
final rankingMonthProvider = StateNotifierProvider((ref) => NewsState("month_ranking"));
final rankingWeekProvider = StateNotifierProvider((ref) => NewsState("week_ranking"));
final rankingDayProvider = StateNotifierProvider((ref) => NewsState("day_ranking"));

class NewsState extends StateNotifier<List>  {
  // NewsState() : super([]);
  NewsState(String type) : super([]) {
    switch (type) {
      case "latest":
        this.getPost(true);
        break;
      case "history":
        this.initHistory("history");
        break;
      case "favorite":
        this.initHistory("favorite");
        break;
      case "month_ranking":
        this.getRanking("monthly");
        break;
      case "week_ranking":
        this.getRanking("weekly");
        break;
      case "day_ranking":
        this.getRanking("daily");
        break;
      case "recommended":
        this.getRecommended();
        break;
    }
    // if (type == "latest") {
    //  this.getPost(true);
    // } else if (type == "history") {
    //   this.initHistory();
    // } else if (type == "ranking") {
    //   this.getRanking();
    // } else if (type == "recommended") {
    //   this.getRecommended();
    // }
  }

  static const String kFileName = 'mySkipIDs.csv';
  File _filePath;
  bool _fileExists = false;

  Map<String, dynamic> data;
  List newsPost = [];
  String lastpublished = "";
  String baseURL = "http://gitouhon-juku-k8s2.ga";

  Box historyBox;
  Box favoriteBox;

  void getPost(bool initFlg) async {
    //print(initFlg);
    if (initFlg) {
      lastpublished = "";
      newsPost = [];
      //print("init latest aaaaaaaaaaaaa");
    }
    _filePath = await _localFile;
    _fileExists = await _filePath.exists();
    var _skipIDs = "";
    if (_fileExists) {
      _skipIDs = await _filePath.readAsString();
    }
    var getPostURL = baseURL + "/mongo/get?lastpublished=" +
        lastpublished +
        "&skipIDs=" +
        _skipIDs;
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);

    newsPost.addAll(data["data"]);
    lastpublished = data["lastpublished"];

    //init readflg
    _initReadFlg();
  }

  void _initReadFlg () async {
    historyBox = await Hive.openBox<HistoryModel>('history');
    favoriteBox = await Hive.openBox<HistoryModel>('favorite');

    for (var newsPostOne in newsPost) {
      if (newsPostOne["readFlg"] != true) {
        var check = historyBox.values.firstWhere(
                (list) => list.id == newsPostOne["_id"],
            orElse: () => null);
        if (check == null) {
          newsPostOne["readFlg"] = false;
        } else {
          newsPostOne["readFlg"] = true;
        }
      }

      //init favorite Flg
      if (newsPostOne["favoriteFlg"] != true) {
        var check = favoriteBox.values.firstWhere(
                (list) => list.id == newsPostOne["_id"],
            orElse: () => null);
        if (check == null) {
          newsPostOne["favoriteFlg"] = false;
        } else {
          newsPostOne["favoriteFlg"] = true;
        }
      }
    }
    state = newsPost;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$kFileName');
  }

  void changeOneLatest(String id) {
    for (var newsPostOne in newsPost) {
      if (newsPostOne["_id"] == id) {
          newsPostOne["readFlg"] = true;
          state = newsPost;
      }
    }
  }

  void changeOneFavorite(String id, bool onFlg) {
    for (var newsPostOne in newsPost) {
      if (newsPostOne["_id"] == id) {
        if (onFlg) {
          newsPostOne["favoriteFlg"] = false;
        } else {
          newsPostOne["favoriteFlg"] = true;
        }
        //print(newsPostOne["titles"]);
        //print(newsPostOne["favoriteFlg"]);

        state = newsPost;
      }
    }
  }

  void initHistory (String type) async {
    //print("init History kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
    historyBox = await Hive.openBox<HistoryModel>(type);
    List<HistoryModel> Items = historyBox.values.toList();
    state = Items;
  }

  void addHistory (HistoryModel history) {
    //print("add history");
    List<HistoryModel> historyItems = state;
    historyItems.add(history);
    state = historyItems;
  }

  void deleteHistory (String delId) {
    //print("delete history");
    List<HistoryModel> historyItems = state;
    for (int index = 0; index < historyItems.length; index++) {
      if (historyItems[index].id == delId) {
        historyItems.removeAt(index);
      }
    }
    state = historyItems;
  }

  void getRanking (String type) async {
    var getPostURL = baseURL + "/mongo/ranking/" + type;
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);

    newsPost = data["data"];
    _initReadFlg();
  }

  void getRecommended () async {
    historyBox = await Hive.openBox<HistoryModel>('history');
    List<HistoryModel> historyItems = historyBox.values.toList();

    if (historyItems.length == 0) {
      var getPostURL = baseURL + "/mongo/ranking";
      http.Response response = await http.get(getPostURL);
      data = json.decode(response.body);

      newsPost = data["data"];
    } else {
      int index = 0;
      String ids = "";
      for (var item in historyItems.reversed) {
        if (ids == "") {
          ids = item.id;
        } else {
          ids = ids + "," + item.id;
        }
        index++;
        //直近閲覧した15の記事からレコメンドを作成
        if (index >= 15) {
          break;
        }
      }

      var getPostURL = baseURL + "/personal?ids=" + ids;
      //print(getPostURL);
      http.Response response = await http.get(getPostURL);
      data = json
          .decode(
          Utf8Decoder(allowMalformed: true).convert(response.bodyBytes));

      //print("aaaaaaaaaaaaaaaaaaaaaaaaaaaa");

      newsPost = data["data"];
    }
    _initReadFlg();
  }

}

