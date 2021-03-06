import 'package:flutter/material.dart';
import 'webview.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class NewsCard extends StatelessWidget {
  final String _id;
  final String image;
  final String publishedAt;
  final String siteID;
  final String sitetitle;
  final String titles;
  final String url;
  static const String placeholderImg = 'assets/images/no_image_square.jpg';
  static const String kFileName = 'myHistoryMod.json';

  NewsCard(
      this._id, this.image, this.publishedAt, this.siteID, this.sitetitle, this.titles, this.url);

  bool _fileExists = false;
  File _filePath;
  List _json = [];
  String _jsonString;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$kFileName');
  }

  void _writeJson(Map<String, dynamic> _newJson) async {
    _filePath = await _localFile;
    _fileExists = await _filePath.exists();

    if (!_fileExists) {
      _filePath.writeAsString('');
    } else {
      _jsonString = await _filePath.readAsString();
      _json = json.decode(_jsonString);
    }
    _json.add(_newJson);
    _jsonString = json.encode(_json);
    _filePath.writeAsString(_jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            child: ListTile(
              leading: thumbnail(image),
              title: title(titles),
              subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    subtitle(publishedAt, Colors.white),
                    subtitle(sitetitle, Colors.red[200]),
                  ]),
              onTap: () {
                var _newJson = {
                  "_id":          this._id,
                  "image":        this.image,
                  "publishedAt":  this.publishedAt,
                  "siteID":       this.siteID,
                  "sitetitle":    this.sitetitle,
                  "titles":       this.titles,
                  "url":          this.url,
                };
                _incrViewCount(_id);
                _writeJson(_newJson);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MatomeWebView(
                          title: titles,
                          selectedUrl: url,
                        )));
              },
            ),
          ),
        ],
      ),
    );
  }

  title(title) {
    return Text(
      title,
      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  subtitle(subTitle, color) {
    return Text(
      subTitle,
      style:
          TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(imageUrl) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => Icon(Icons.error),
        //=> Image.asset(placeholderImg),
        errorWidget: (context, url, error) => Icon(Icons.error),
        // errorImage
        height: 50,
        width: 50,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }

  Future _incrViewCount(String id) async {
    var _incrViewCountURL = "http://gitouhon-juku-k8s2.ga/redis/put/";
    await http.get(_incrViewCountURL + id);
  }
}

class NewsRankingCard extends NewsCard {
  NewsRankingCard(String _id, String image, String publishedAt, String siteID, String sitetitle, String titles, String url)
      : super(_id, image, publishedAt, siteID, sitetitle, titles, url);

  @override
  thumbnail(title) {
    return Text(
      title,
      style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
