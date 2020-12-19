import 'package:flutter/material.dart';
import 'screens/news_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "まとめさん",
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: NewsListScreen(),
    );
  }
}
