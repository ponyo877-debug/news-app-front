import 'package:flutter/material.dart';
import 'webview.dart';
import 'select_sites.dart';

class SettingScreen extends StatelessWidget {
  // final String contactURL = "https://forms.gle/PBs2r2YBbzzdQZd29";
  final String contactURL =
      "https://docs.google.com/forms/d/e/1FAIpQLSd-fuupDifDoJQ1uTkdyUCgzEiNvfUzdJe0YOhPfdSC3U2Erw/viewform?usp=sf_link";
  final String PPURL = "http://gitouhon-juku-k8s2.ga/privacy_policy/";

  @override
  Widget build(BuildContext context) {
    //return MaterialApp(
      //debugShowCheckedModeBanner: false,
      //title: "SETTING",
      return Scaffold(
        body: ListView.separated(
          itemCount: 3,
          separatorBuilder:
              (BuildContext context, int index) => Divider(
                  color: Colors.white),
          itemBuilder: (BuildContext context, int index) {
            Widget listtile;
            switch (index) {
              case 0:
                listtile = ListTile(
                  leading: Icon(Icons.select_all),
                  title: Text(
                    'Select Site',
                    style: TextStyle(fontSize: 20),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SelectSites()));
                  },
                );
                break;
              case 1:
                listtile = ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text(
                    'Contact Us',
                      style: TextStyle(fontSize: 20),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    print(contactURL);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            MatomeWebView(
                              title: "Contact Us",
                              selectedUrl: contactURL,
                            )));
                  },
                );
                break;
              case 2:
                listtile = ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text(
                    'Privacy Policy',
                      style: TextStyle(fontSize: 20),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    print(PPURL);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            MatomeWebView(
                              title: "Privacy Policy",
                              selectedUrl: PPURL,
                            )));
                  },
                );
                break;
            }
            return listtile;
          },
        ),
      );
  }
}
