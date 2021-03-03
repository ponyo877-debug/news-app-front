import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SelectSites extends StatefulWidget {
  @override
  _SelectSites createState() => _SelectSites();
}

class _SelectSites extends State<SelectSites>{

  Future<bool> _future;

  String baseURL = "http://gitouhon-juku-k8s2.ga";
  Map<String, dynamic> data;
  List newsList = [];

  //file
  File _filePath;
  static const String kFileName = 'mySkipIDs.csv';
  bool _fileExists = false;

  @override
  void initState() {
    super.initState();
    _future = _getInitSiteList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        String _newData = '';
        for (int i = 0; i < newsList.length; i++) {
          if (newsList[i]["switchValue"] == false) {
            _newData = '$_newData${newsList[i]["siteID"]},';
          }
        }
        _writeJson(_newData);
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('表示サイトの選択'),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget childWidget;
            if (!snapshot.hasData) {
              childWidget = Center(child: CircularProgressIndicator());
            } else {
              childWidget = ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black38),
                        ),
                      ),
                      child: SwitchListTile(
                        value: newsList[index]["switchValue"],
                        title: Text(
                          "${newsList[index]["sitetitle"]}",
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            //fontFamily: 'Cursive',
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            newsList[index]["switchValue"] = value;
                          });
                        },
                        secondary: thumbnail(newsList[index]["image"]),
                      )
                  );
                },
                itemCount: newsList.length,
              );
            }
            return childWidget;
          }
        )
    ),
    );
  }

  Future<bool> _getInitSiteList() async {

    var getSiteList = baseURL + "/site/get";
    http.Response response = await http.get(getSiteList);
    data = json.decode(response.body);
    if (mounted) {
      setState(() {
        newsList = data["data"];
      });
    }

    //read File
    _filePath = await _localFile;
    _fileExists = await _filePath.exists();

    if (!_fileExists) {
      for (int i = 0; i < newsList.length; i++) {
        newsList[i]["switchValue"] = true;
      }
    } else {
      var _fileData = await _filePath.readAsString();
      for (int i = 0; i < newsList.length; i++) {
        var siteID = _fileData.split(",");
        var flgSite = true;
        for (int j = 0; j < siteID.length; j++) {
          if (newsList[i]["siteID"].toString() == siteID[j].toString() ) {
            flgSite = false;
          }
        }
        newsList[i]["switchValue"] = flgSite;
      }
    }
    return true;
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$kFileName');
  }

  void _writeJson(String _newData) async {
    _filePath = await _localFile;
    _fileExists = await _filePath.exists();

    if (!_fileExists) {
       _filePath.writeAsString('');
    }
    _filePath.writeAsString(_newData);
  }
}
