import 'user_model.dart';

class Message {
  final User sender;
  final String avatar;
  final String time;
  final String text;

  Message({
    this.sender,
    this.avatar,
    this.time,
    this.text,
  });
}

String addison_avatar = 'https://img.gitouhon-juku-k8s2.ga/default_0.jpg';

final List<Message> messages = [
  Message(
    sender: currentUser,
    time: '12:09 AM',
    avatar: addison_avatar,
    text: "これでさよなら、あなたのことが何よりも大切でした",
  ),
  Message(
    sender: addison,
    time: '12:05 AM',
    text: "望み通りの終わりじゃなかった、あなたはどうですか?",
  ),
  Message(
    sender: angel,
    time: '12:05 AM',
    text: "友達にすら戻れないから私、空を見ていました",
  ),
  Message(
    sender: deanna,
    time: '11:58 PM',
    avatar: addison_avatar,
    text: "最後くらいまた春めくような綺麗なさようならしましょう",
  ),
  Message(
    sender: jason,
    time: '11:58 PM',
    avatar: addison_avatar,
    text: "それは水もやらず枯れたエーデルワイス",
  ),
  Message(
    sender: judd,
    time: '11:45 PM',
    text: "黒ずみ出す耳飾りこんなつまらない映画などもうおしまい",
  ),
  Message(
    sender: leslie,
    time: '11:30 PM',
    avatar: addison_avatar,
    text: "なのにエンドロールの途中で悲しくなった。ねぇ、この想いは何?",
  ),
];
