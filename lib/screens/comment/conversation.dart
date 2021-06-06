import 'comment_model/message_model.dart';
import 'comment_model/user_model.dart';
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
  const Conversation({Key key, this.articleID}) : super(key: key);

  @override
  _Conversation createState() => _Conversation();
  final String articleID;
}

class _Conversation extends State<Conversation> {
  String _deviceIdHash;
  List commentList = [];
  String baseURL = "http://gitouhon-juku-k8s2.ga";

  @override
  void initState() {
    super.initState();
    print("initState");
    setDiveceIdHash();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    var num_comment = commentList == null? 0: commentList.length;
    if (num_comment == 0) {
      return ListView(children: [SizedBox(height: 10),Center(child: Text("コメントはありません"))]);
    } else {
      print("%%%%%%%%%%");
      return ListView.builder(
          reverse: false, // コメント順: 新規が下
          itemCount: num_comment,
          itemBuilder: (context, int index) {
            print('commentList[index] ${commentList[index]}');
            final comment = commentList[index];
            bool isMe = comment["deviceHash"] == _deviceIdHash;
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
                          backgroundImage: NetworkImage(
                              comment["avatar"]),
                        ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                          padding: EdgeInsets.all(10),
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.75),
                          decoration: BoxDecoration(
                              color:
                              isMe ? MyTheme.kAccentColor : Colors.grey[200],
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
                      mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isMe)
                          SizedBox(
                            width: 40,
                          ),
                        Text(
                          comment["postDate"],
                          style: MyTheme.bodyTextTime,
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

  Future setDiveceIdHash() async {
    var digest = await getDeviceIdHash();
    if (mounted) {
      setState(() {
        _deviceIdHash = digest;
      });
    }
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
