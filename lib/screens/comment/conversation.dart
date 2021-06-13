import 'chat_theme.dart';
import 'get_device_hash.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// https://konifar.hatenablog.com/entry/2018/02/11/081031
// https://zenn.dev/hayabusabusa/articles/7bf73f007584aa4e0ee8
class Conversation extends StatefulWidget {
  const Conversation(
      {Key key, @required this.articleID, @required this.deviceHash})
      : super(key: key);

  @override
  _Conversation createState() => _Conversation();
  final String articleID;
  final String deviceHash;
}

class _Conversation extends State<Conversation> {
  // String _deviceIdHash;
  List commentList = [];
  String baseURL = "http://gitouhon-juku-k8s2.ga";

  @override
  void initState() {
    super.initState();
    print("initState");
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    var num_comment = commentList == null ? 0 : commentList.length;
    if (num_comment == 0) {
      return ListView(
          children: [SizedBox(height: 10), Center(child: Text("コメントはありません"))]);
    } else {
      print("%%%%%%%%%%");
      return ListView.builder(
          reverse: false, // コメント順: 新規が下
          itemCount: num_comment,
          itemBuilder: (context, int index) {
            print('commentList[index] ${commentList[index]}');
            final comment = commentList[index];
            bool isMe = comment["deviceHash"] == widget.deviceHash;
            return Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe)
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(comment["avatar"]),
                        ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                          padding: EdgeInsets.all(10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                              color: isMe
                                  ? MyTheme.kAccentColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(isMe ? 15 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 15),
                              )),
                          child: Column(
                            children: [
                              if (!isMe)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment["username"],
                                      textAlign: TextAlign.right,
                                      style: MyTheme.bodyTextMessage.copyWith(
                                        color: Colors.lightBlue,
                                      ),
                                    ),
                                    Text(comment["deviceHash"].substring(0, 6),
                                        textAlign: TextAlign.right,
                                        style: MyTheme.bodyTextMessage.copyWith(
                                          color: Colors.grey[400],
                                        )),
                                  ],
                                ),
                              Text(
                                comment["massage"],
                                textAlign: TextAlign.left,
                                style: MyTheme.bodyTextMessage.copyWith(
                                    color:
                                        isMe ? Colors.white : Colors.grey[800]),
                              )
                            ],
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe)
                          SizedBox(
                            width: 40,
                          ),
                        Text(
                          comment["postDate"],
                          style: MyTheme.bodyTextTime,
                        ),
                        if (!isMe)
                          SizedBox(
                            width: 20,
                          ),
                        if (!isMe)
                          GestureDetector(
                            child: Icon(Icons.announcement_rounded,
                                color: Color(0xffAEABC9)),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    new AlertDialog(
                                  title: Text("通報理由を入力してください"),
                                  content: Container(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                        Text('user: ' + comment["username"]),
                                        Text('message: ' + comment["massage"]),
                                            ReportDropdown(dropdownList: <String>[
                                          '通報理由を選択',
                                          '性的な内容',
                                          '出会い目的',
                                          '荒らし',
                                          '他アプリへの移動',
                                          '勧誘・営業',
                                          '犯罪行為',
                                          'その他'
                                        ]),
                                        Text("通報内容はアプリ管理者に報告されます"),
                                      ])),
                                  // ボタンの配置
                                  actions: <Widget>[
                                    new TextButton(
                                        child: const Text('キャンセル'),
                                        onPressed: () {
                                          print('Cancel!');
                                          Navigator.pop(context);

                                        }),
                                    new TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          print('Ok!');
                                          execWebHook(comment["massage"]);
                                          Navigator.pop(context);
                                        })
                                  ],
                                ),
                              );
                            },
                          )
                      ],
                    ),
                  )
                ],
              ),
            );
          });
    }
  }


  Future execWebHook(String message) async {
    var slackWebhookURL = "https://hooks.slack.com/services/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";
    String body = json.encode(
        {'text': '\'' + message + '\'が通報されました'});
    print('slackWebhookURL: $slackWebhookURL');
    http.Response res = await http.post(slackWebhookURL, body: body);
  }


  Future getComments() async {
    var getCommentURL = baseURL + "/comment/get?articleID=" + widget.articleID;
    print('getCommentURL: $getCommentURL');
    http.Response response = await http.get(getCommentURL);
    var data = json.decode(response.body);
    if (mounted) {
      setState(() {
        commentList = data["data"];
      });
    }
  }
}

class ReportDropdown extends StatefulWidget {
  const ReportDropdown({Key key, @required this.dropdownList,}) : super(key: key);

  @override
  State<ReportDropdown> createState() => _ReportDropdown();
  final List<String> dropdownList;
}

/// This is the private State class that goes with MyStatefulWidget.
class _ReportDropdown extends State<ReportDropdown> {
  String dropdownValue = '通報理由を選択';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: widget.dropdownList
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: value == "通報理由を選択"? Colors.grey: Colors.white),),
        );
      }).toList(),
    );
  }
}