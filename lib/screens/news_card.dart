import 'package:flutter/material.dart';
import 'webview.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'models/history_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'news_state.dart';

class NewsCard extends StatelessWidget {
  String _id;
  String image;
  String publishedAt;
  String siteID;
  String sitetitle;
  String titles;
  String url;
  //bool colorChange = true;
  bool readFlg = false;
  static const String placeholderImg = 'assets/images/no_image_square.jpg';

  NewsCard(this._id, this.image, this.publishedAt, this.siteID, this.sitetitle,
      this.titles, this.url, this.readFlg);

  Future _addHistory(HistoryModel historyModel) async {
    final historyBox = await Hive.openBox<HistoryModel>('history');
    historyBox.add(historyModel);
  }

  @override
  Widget build(BuildContext context) {
    //bloc = NewsBlocProvider.of(context).bloc;
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            child: ListTile(
              leading: thumbnail(this.image),
              title: title(this.titles,
                  this.readFlg ? Colors.grey : Colors.white, this.readFlg),
              subtitle: Wrap(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  alignment: WrapAlignment.spaceBetween,
                  verticalDirection: VerticalDirection.up,
                  children: <Widget>[
                    subtitle(this.publishedAt,
                        this.readFlg ? Colors.grey : Colors.white),
                    subtitle(this.sitetitle,
                        this.readFlg ? Colors.grey : Colors.red[200]),
                  ]),
              // TODO: Need to implement favorite button
              // trailing: widget.publishedAt != ""
              //     ? IconButton(
              //         icon: Icon(Icons.favorite_border),
              //         onPressed: () {
              //           print('Push ${widget._id}\'s Favorite Button!');
              //           final newfavorite = HistoryModel(
              //               widget._id,
              //               widget.image,
              //               widget.publishedAt,
              //               widget.siteID,
              //               widget.sitetitle,
              //               widget.titles,
              //               widget.url);
              //           _addFavorite(newfavorite);
              //         },
              //       )
              //     : null,
              onTap: () {
                final newHistory = HistoryModel(
                  _id,
                  image,
                  publishedAt,
                  siteID,
                  sitetitle,
                  titles,
                  url,
                ); // int.parse(_age));
                _addHistory(newHistory);
                context.read(newsProvider.notifier).changeOneLatest(_id);
                context.read(rankingProvider.notifier).changeOneLatest(_id);
                context.read(historyProvider.notifier).addHistory(newHistory);
                _incrViewCount(_id);

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MatomeWebView(
                          title: titles,
                          postID: _id,
                          selectedUrl: url,
                          siteID: siteID,
                        )));
              },
            ),
          ),
        ],
      ),
    );
  }

  title(title, color, readFlg) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 15.0,
          color: color,
          fontWeight: readFlg ? FontWeight.w100 : FontWeight.w500),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  subtitle(subTitle, color) {
    return Text(
      subTitle,
      style:
          TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
          // border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      placeholder: (context, url) => Icon(Icons.error),
      errorWidget: (context, url, error) => Icon(Icons.error),
      // errorImage
      height: 60,
      width: 60,
      alignment: Alignment.center,
      // fit: BoxFit.cover,
    );
  }

  Future _incrViewCount(String id) async {
    var _incrViewCountURL = "http://gitouhon-juku-k8s2.ga/redis/put/";
    await http.get(_incrViewCountURL + id);
  }
}

class NewsRankingCard extends NewsCard {
  NewsRankingCard(String _id, String image, String publishedAt, String siteID,
      String sitetitle, String titles, String url, bool readFlg)
      : super(_id, image, publishedAt, siteID, sitetitle, titles, url, readFlg);

  @override
  thumbnail(rank) {
    return Text(
      rank,
      style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class NewsHistoryCard extends NewsCard {
  NewsHistoryCard(String _id, String image, String publishedAt, String siteID,
      String sitetitle, String titles, String url, bool readFlg)
      : super(_id, image, publishedAt, siteID, sitetitle, titles, url, readFlg);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            child: ListTile(
              leading: thumbnail(this.image),
              title: title(this.titles, Colors.white, false),
              subtitle: Wrap(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  alignment: WrapAlignment.spaceBetween,
                  verticalDirection: VerticalDirection.up,
                  children: <Widget>[
                    subtitle(this.publishedAt, Colors.white),
                    subtitle(this.sitetitle, Colors.red[200]),
                  ]),
              // TODO: Need to implement favorite button
              // trailing: widget.publishedAt != ""
              //     ? IconButton(
              //         icon: Icon(Icons.favorite_border),
              //         onPressed: () {
              //           print('Push ${widget._id}\'s Favorite Button!');
              //           final newfavorite = HistoryModel(
              //               widget._id,
              //               widget.image,
              //               widget.publishedAt,
              //               widget.siteID,
              //               widget.sitetitle,
              //               widget.titles,
              //               widget.url);
              //           _addFavorite(newfavorite);
              //         },
              //       )
              //     : null,
              onTap: () {
                final newHistory = HistoryModel(
                  this._id,
                  this.image,
                  this.publishedAt,
                  this.siteID,
                  this.sitetitle,
                  this.titles,
                  this.url,
                ); // int.parse(_age));
                _addHistory(newHistory);
                _incrViewCount(this._id);

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MatomeWebView(
                          title: titles,
                          postID: _id,
                          selectedUrl: url,
                          siteID: siteID,
                        )));
              },
            ),
          ),
        ],
      ),
    );
  }
}
