import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'news_card.dart';

// import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../service/admob.dart';
import 'package:admob_flutter/admob_flutter.dart';

// WebViewController _controller;
class MatomeWebView extends StatefulWidget {
  final String title;
  final String postID;
  final String selectedUrl;
  final String siteID;

  MatomeWebView(
      {Key key, this.title, this.postID, this.selectedUrl, this.siteID})
      : super(key: key);

  @override
  _MatomeWebView createState() => _MatomeWebView();
}

class _MatomeWebView extends State<MatomeWebView> {
  var notLiveDoorIDs = [
    2,
  ];
  // add_20201227
  WebViewController _controller;
  String baseURL = "http://gitouhon-juku-k8s2.ga";
  Map<String, dynamic> data;
  List recomPost = [];
  bool isOpen = false;
  double dist_threshold = 0.1;

  Future _getRecom(String postID) async {
    var getRecomURL = baseURL + "/recom/" + postID;
    print('getRecomURL: $getRecomURL');
    http.Response response = await http.get(getRecomURL);
    data = json
        .decode(Utf8Decoder(allowMalformed: true).convert(response.bodyBytes));
    if (mounted) {
      setState(() {
        var postTmps = data["data"];
        for (var postTmp in postTmps) {
          if (postTmp["distance"] > dist_threshold) {
            recomPost.add(postTmp);
          }
        }
      });
    }
  }

  // use to normal webview using initialUrl
  // final Completer<WebViewController> controller = Completer<WebViewController>();
  // MatomeWebView({this.title, this.selectedUrl});
  Future<dom.Document> arrangeArticleBody(dom.Document doc) async {
    var articleBody = doc.querySelector('div#article-contents.article-body');

    var pageCount;
    var nextPage = doc.body.querySelector('p.next');
    if (nextPage != null) {
      pageCount = int.parse(
          doc.body.querySelector('p.page-current').text.split('/').last);
    }
    doc.body.querySelector('div.article-body-outer').children.clear();
    doc.body.querySelector('div.article-body-outer').children.add(articleBody);
    if (nextPage != null) {
      var nextUrl = nextPage.querySelector('a').attributes['href'];
      for (int p = 2; p <= pageCount; p++) {
        var nextBody = await getNextPage(nextUrl, p);
        doc.body.querySelector('div.article-body-outer').children.add(nextBody);
      }
    }
    return doc;
  }

  dom.Document arrangeHeader(dom.Document doc) {
    var linkstyle = doc.head.querySelectorAll('link[rel="stylesheet"]');
    var orgstyle = doc.head.querySelector('style');
    var viewport = doc.head.querySelector('meta[name="viewport"]');
    doc.head.children.clear();
    for (int i = 0; i < linkstyle.length; i++) {
      doc.head.children.add(linkstyle[i]);
    }
    if (orgstyle != null) {
      doc.head.children.add(orgstyle);
    }
    if (viewport != null) {
      doc.head.children.add(viewport);
    }
    return doc;
  }

  dom.Document arrangeBody(dom.Document doc) {
    var articleHeaders = doc.querySelectorAll('header.section-box');
    var blogTitle = articleHeaders[0];
    var articleTitle = articleHeaders[1];
    var temp = doc.body.querySelector('div.article-body-outer');
    doc.body.querySelector('div.content').children.clear();
    doc.body.querySelector('div.content').children.add(blogTitle);
    doc.body.querySelector('div.content').children.add(articleTitle);
    doc.body.querySelector('div.content').children.add(temp);

    temp = doc.body.querySelector('div.content');
    doc.body.querySelector('div.container-inner').children.clear();
    doc.body.querySelector('div.container-inner').children.add(temp);

    temp = doc.body.querySelector('div.container-inner');
    doc.body.querySelector('div.container').children.clear();
    doc.body.querySelector('div.container').children.add(temp);

    temp = doc.body.querySelector('div.container');
    doc.body.children.clear();
    doc.body.children.add(temp);
    return doc;
  }

  Future<String> arrangeforLivedoorBlog(dom.Document doc) async {
    doc = arrangeHeader(doc);
    doc = await arrangeArticleBody(doc);
    doc = arrangeBody(doc);

    var siteIdStr = widget.siteID.toString();
    switch (siteIdStr) {
      case '3':
        doc = modforNewSoku(doc);
        break;
      case '5':
        doc = modforHimaSoku(doc);
        break;
      case '6':
        doc = modforVipper(doc);
        break;
      case '7':
        doc = modforWaraNote(doc);
        break;
      case '9':
        doc = modforInazumaSoku(doc);
        break;
      case '10':
        doc = modforTetsugakuNews(doc);
        break;
    }

    var modifiedHtml = Uri.dataFromString(
            doc.head.outerHtml + doc.body.outerHtml,
            mimeType: 'text/html',
            encoding: Encoding.getByName('UTF-8'))
        .toString();
    return modifiedHtml;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          future: _loadUri(widget.selectedUrl),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return WebView(
                // initialUrl: widget.selectedUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  // controller.complete(webViewController);
                  _controller = webViewController;
                  print(snapshot.data);
                  _controller.loadUrl(snapshot.data);
                  _getRecom(widget.postID);
                },
              );
            } else {
              return new Center(
                child: new Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  width: 32.0,
                  height: 32.0,
                  child: const CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        bottomNavigationBar: Platform.isAndroid? AdmobBanner(
          adUnitId: AdMobService().getBannerAdUnitId(),
          adSize: AdmobBannerSize(
            width: MediaQuery.of(context).size.width.toInt(),
            height: AdMobService().getHeight(context).toInt(),
            name: 'BANNER',
          ),
        ): null,
        floatingActionButton: recomPost.isNotEmpty? Builder(
          builder: (context) => _getRecomkButton(context),
        ): null,
    );
  }

  _getRecomkButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      child: Icon(Icons.bolt, color: Colors.amberAccent, size: 50),
      onPressed: () async {
        if (isOpen) {
          Navigator.pop(context);
          setState(() {
            isOpen = false;
          });
        } else {
          print('Push Bolt Button!');
          Scaffold.of(context).showBottomSheet<void>(
            (BuildContext context) {
              return Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                    itemCount: recomPost.length,
                    scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: NewsCard(
                            "${recomPost[index]["_id"]}",
                            "${recomPost[index]["image"]}",
                            "",
                            // "${recomPost[index]["publishedAt"]}",
                            "${recomPost[index]["siteID"]}",
                            "${recomPost[index]["sitetitle"]}",
                            "${recomPost[index]["titles"]}",
                            "${recomPost[index]["url"]}",
                            false,
                            false,
                        ),
                      );
                    },
                  ));
            },
          );
          setState(() {
            isOpen = true;
          });
        }
      },
    );
  }

  Future<dom.Element> getNextPage(String Url, int p) async {
    var nextUrl = Url.replaceFirst('p=2', 'p=' + p.toString());
    var nextBody = await _loadUriDom(nextUrl);
    return nextBody.querySelector('div#article-contents.article-body');
  }

  dom.Document modforHimaSoku(dom.Document doc) {
    var temp = doc.body.querySelector('div.article_mid_v2');
    if (temp != null) {
      temp.remove();
    }
    temp = doc.body.querySelector('div#article_low_v2');
    if (temp != null) {
      temp.remove();
    }
    var scriptTag = doc.body.querySelectorAll('iframe');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    return doc;
  }

  dom.Document modforNewSoku(dom.Document doc) {
    var temp = doc.body.querySelector(
        'script[src="https://blogroll.livedoor.net/js/blogroll.js"]');
    if (temp != null) {
      temp.remove();
    }
    var scriptTag = doc.body.querySelectorAll('div#f984a');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    return doc;
  }

  dom.Document modforVipper(dom.Document doc) {
    var scriptTag = doc.body.querySelectorAll('a');
    var scriptTagwithBR = doc.body.querySelectorAll('br');
    var allbrcount = scriptTagwithBR.length;
    for (int i = 0; i < scriptTag.length; i++) {
      var hrefurl = scriptTag[i].attributes['href'];
      if (hrefurl.startsWith('http://blog.livedoor.jp/news23vip/archives/')) {
        doc.body.querySelector('a[href="$hrefurl"]').remove();
        scriptTagwithBR[allbrcount - (i + 1)].remove();
      }
    }
    return doc;
  }

  // TODO: Need to implement
  dom.Document modforWaraNote(dom.Document doc) {
    // Delete: div class "amazon Default"
    // Delete: a[href][target="_blank"]:not([class]):not([href="^https://livedoor.blogimg.jp/waranote2/imgs/"])
    var temp = doc.body.querySelector('div.amazon.Default');
    if (temp != null) {
      temp.remove();
    }
    temp = doc.body.querySelector('span[style="color:#006600"]');
    if (temp != null) {
      temp.remove();
    }
    var scriptTag = doc.body.querySelectorAll('a[href][title]:not([class])');
    var scriptTagwithBR = doc.body.querySelectorAll('br');
    var allbrcount = scriptTagwithBR.length;
    for (int i = 0; i < scriptTag.length; i++) {
      var hrefurl = scriptTag[i].attributes['href'];
      if (!hrefurl.startsWith('https://livedoor.blogimg.jp/waranote2/imgs/')) {
        doc.body.querySelector('a[href="$hrefurl"]').remove();
        scriptTagwithBR[allbrcount - (2 * i + 1)].remove();
        scriptTagwithBR[allbrcount - (2 * i + 2)].remove();
      }
    }
    scriptTag = doc.body.querySelectorAll('a[href][target="_blank"]:not([class])');
    scriptTagwithBR = doc.body.querySelectorAll('br');
    allbrcount = scriptTagwithBR.length;
    for (int i = 0; i < scriptTag.length; i++) {
      var hrefurl = scriptTag[i].attributes['href'];
      if (!hrefurl.startsWith('https://livedoor.blogimg.jp/waranote2/imgs/')) {
        doc.body.querySelector('a[href="$hrefurl"]').remove();
        scriptTagwithBR[allbrcount - (2 * i + 1)].remove();
        scriptTagwithBR[allbrcount - (2 * i + 2)].remove();
      }
    }
    var length_for_delete = scriptTagwithBR.length;
    for (int i = 0; i < 6; i++){
      scriptTagwithBR[length_for_delete - (i + 1)].remove();
    }
    return doc;
  }

  // TODO: Need to implement
  dom.Document modforInazumaSoku(dom.Document doc) {
    // Detele: div class ika2
    // Delete: ul id anop
    var temp = doc.body.querySelector('div.ika2');
    if (temp != null) {
      temp.remove();
    }
    temp = doc.body.querySelector('ul#anop');
    if (temp != null) {
      temp.remove();
    }
    return doc;
  }

  // TODO: Need to implement
  dom.Document modforTetsugakuNews(dom.Document doc) {
    // Delete: span style="font-size: large;"
    var temp = doc.body.querySelector('span[style="font-size: large;"]');
    if (temp != null) {
      temp.remove();
    }
    return doc;
  }


  Future<String> _loadUri(loaduri) async {
    String userAgent, _decode_charset;
    try {
      userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
      // print("userAgent: ${userAgent}");
    } on PlatformException {
      userAgent = '<error>';
    }
    if (Platform.isIOS) {
      userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1';
    }
    var response = await http.Client()
        .get(Uri.parse(loaduri), headers: {'User-Agent': userAgent});
    // print("response status: ${response.statusCode}");
    // print("response.headers: ${response.headers['content-type']}");

    // int response_length = response.bodyBytes.length;
    // String decoded = await CharsetConverter.decode("UTF-8", response.bodyBytes);
    String decoded =
        Utf8Decoder(allowMalformed: true).convert(response.bodyBytes);

    if (response.statusCode == 200) {
      var _headers = response.headers['content-type'].split('charset=');
      // print("response.headers: " + response.headers['content-type']);

      if (_headers.length == 2) {
        _decode_charset = _headers.last;
      } else {
        _decode_charset = 'utf-8';
      }
      // print("headers: ${_headers.length}");

      String modifiedHtml;
      // var hostName = Uri.parse(loaduri).host;
      //if (livedoorhosts.contains(hostName)) {
      if (notLiveDoorIDs.contains(widget.siteID)) {
        modifiedHtml = Uri.dataFromString(decoded,
                mimeType: 'text/html', encoding: Encoding.getByName('UTF-8'))
            .toString();
      } else {
        modifiedHtml = await arrangeforLivedoorBlog(parse(decoded));
      }
      return modifiedHtml;
    } else {
      var notFoundPage = "\<title\>この記事は削除されたようです\</title\>\<style\>*{box-sizing:border-box}body{font:110%/1.5 system-ui,sans-serif;background:#131417;color:#fff;height:100vh;margin:0;display:grid;place-items:center;padding:2rem}main{max-width:350px}a{color:#56bbf9}\</style\>\<main\>\<h1 data-test-id=\"text-404\"\>おそらくこの記事は削除されています\</h1\>\<p\>申し訳ありませんが他の記事を参照下さい、右下に稲妻マークがあればこの記事の関連記事を確認できます。\</main\>";
      return Uri.dataFromString(notFoundPage,
          mimeType: 'text/html', encoding: Encoding.getByName('UTF-8'))
          .toString();
    }
  }

  Future<dom.Document> _loadUriDom(loaduri) async {
    String userAgent, _decode_charset;
    try {
      userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
      // print("userAgent: ${userAgent}");
    } on PlatformException {
      userAgent = '<error>';
    }
    if (Platform.isIOS) {
      userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1';
    }
    var response = await http.Client()
        .get(Uri.parse(loaduri), headers: {'User-Agent': userAgent});
    // print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      var _headers = response.headers['content-type'].split('charset=');
      if (_headers.length == 2) {
        _decode_charset = _headers.last;
      } else {
        _decode_charset = 'utf-8';
      }
      // print("headers: ${_headers.length}");
      String decoded =
          Utf8Decoder(allowMalformed: true).convert(response.bodyBytes);
      // print("_decode_charset: ${_decode_charset}");
      // print("response.bodyBytes: ${response.bodyBytes}");
      return parse(decoded);
    } else {
      throw Exception();
    }
  }
}

class NormalWebView extends StatefulWidget {
  final String title;
  final String selectedUrl;

  NormalWebView({Key key, this.title, this.selectedUrl}) : super(key: key);

  @override
  _NormalWebView createState() => _NormalWebView();
}

class _NormalWebView extends State<NormalWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.selectedUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        );
      }),
    );
  }
}
