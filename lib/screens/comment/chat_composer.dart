import 'package:flutter/material.dart';
import 'chat_theme.dart';
import 'package:http/http.dart' as http;

class buildChatComposer extends StatefulWidget {
  const buildChatComposer(
      {Key key, @required this.articleID, @required this.deviceHash})
      : super(key: key);

  @override
  _buildChatComposer createState() => _buildChatComposer();
  final String articleID;
  final String deviceHash;
}

// https://github.com/cybdom/messengerish
// https://github.com/itzpradip/flutter-chat-app
// https://github.com/tonydavidx/chattie-ui-design
class _buildChatComposer extends State<buildChatComposer> {
// Future<Container> buildChatComposer(String _articleID, String _devideHash) async {
  var _controller = TextEditingController();
  String baseURL = "https://gitouhon-juku-k8s2.ga";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      height: 60,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '記事へコメント',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          GestureDetector(
            child: CircleAvatar(
              backgroundColor: MyTheme.kAccentColor,
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
            onTap: () async {
              var message = _controller.text;
              var putCommentURL = baseURL + "/comment/put";
              var map = new Map<String, dynamic>();
              map["articleID"] = widget.articleID;
              map["massage"] = message;
              map["devicehash"] = widget.deviceHash;
              print('putCommentURL: $putCommentURL');
              http.Response res = await http.post(putCommentURL, body: map);
              print('deviceHash: ${widget.deviceHash}');
              print('http.Response: ${res.statusCode}');

              _controller.clear();
            },
          )
        ],
      ),
    );
  }
}
