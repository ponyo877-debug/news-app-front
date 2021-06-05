import 'package:flutter/material.dart';
import 'comment/conversation.dart';
import 'comment/chat_composer.dart';
import 'comment/chat_theme.dart';
import 'comment/comment_model/user_model.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({Key key, @required this.user}) : super(key: key);

  @override
  _CommentScreen createState() => _CommentScreen();
  final User user;
}

// https://github.com/cybdom/messengerish
// https://github.com/itzpradip/flutter-chat-app
// https://github.com/tonydavidx/chattie-ui-design
class _CommentScreen extends State<CommentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "記事のタイトル or",
                    style: MyTheme.chatSenderName,
                  ),
                  Text(
                    '記事自身の縮小版',
                    style: MyTheme.chatSenderName,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // コメントを打つためのTextFieldをコメント画面をタップすると縮小する
                // Old Ver: FocusScope.of(context).unfocus();
                final FocusScopeNode currentScope = FocusScope.of(context);
                if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                  FocusManager.instance.primaryFocus.unfocus();
                }
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      // 画像などのコンテンツの角を丸くする
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        // コメントの一覧
                        // child: Conversation(user: widget.user),
                        child:
                            Conversation(articleID: "60b79fc6c6b0062d9e484272"),
                      ),
                    ),
                  ),
                  // コメント記入フォーム
                  buildChatComposer(
                      articleID: "60b79fc6c6b0062d9e484272",
                      devideHash: "30224d5d5fcc0f5f5d04e5969179bcdbe6a9438f"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
