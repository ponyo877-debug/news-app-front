import 'package:flutter/material.dart';
import 'chat_theme.dart';
import 'package:http/http.dart' as http;

class buildChatComposer extends StatefulWidget {
  const buildChatComposer(
      {Key key, @required this.articleID, @required this.devideHash})
      : super(key: key);

  @override
  _buildChatComposer createState() => _buildChatComposer();
  final String articleID;
  final String devideHash;
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
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '記事への思いを書いて頂ければ...',
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
            onTap: () async {
              var message = _controller.text;
              print('message: $message');
              var putCommentURL = baseURL + "/comment/put";
              var map = new Map<String, dynamic>();
              map["articleID"] = widget.articleID;
              map["massage"] = message;
              map["devicehash"] = widget.devideHash;
              print('putCommentURL: $putCommentURL');
              print('map["articleID"]: ${map["articleID"]}');
              print('map["massage"]: ${map["massage"]}');
              print('map["devicehash"]: ${map["devicehash"]}');
              // TODO: Need to implement
              // curl -X POST -F articleID=60b79fc6c6b0062d9e484272 -F 'massage=super bunny man' -F devicehash=30224d5d5fcc0f5f5d04e5969179bcdbe6a9438f https://gitouhon-juku-k8s2.ga/comment/put
              // refer: https://stackoverflow.com/questions/57846215/how-make-a-http-post-using-form-data-in-flutter
              http.Response _ = await http.post(putCommentURL, body: map);
              _controller.clear();
            },
            child: CircleAvatar(
              backgroundColor: MyTheme.kAccentColor,
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
