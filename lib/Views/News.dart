import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api.dart';
import '../main.dart';


class News extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewsState();
  }
}

class NewsState extends State<News> {
  static const dateStyle        = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle       = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 1);
  static const descriptionStyle = const TextStyle(fontSize: 15);
  static const subTextStyle     = const TextStyle(fontSize: 10);
  var usableWidth               = 0.0;

  List<Widget> articles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    var request = await KAGApp.api.getAPIRequest(APIAction.GET_ARTICLE);
    var response = await request.getArticles();
    if (response == null) return;
    List<Widget> newArticles = [];
    var entries = jsonDecode(response)['entities'];
    entries.forEach((article) => newArticles.add(_generateRow(article)));
    setState(() {
      articles = newArticles;
    });
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    usableWidth = width - 22; //With image: 132

    return Scaffold(
        appBar: AppBar(
            title: Align(
              child: Text(
                "Aktuelles",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              alignment: Alignment.centerLeft,
            )
        ),
        body: SafeArea(
            child: ListView(
          children: articles,
        )
        )
    );
  }

  Widget _generateRow(article) {
    var title = article['title'] == null ? "" : article['title'];
    var descriptionText = article['preview'] == null ? "" : article['preview'];
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(article['created'] * 1000);
    var date = "${dateTime.day}.${dateTime.month}.${dateTime.year}";
    var author = article['author'] == null ? "" : article['author'];

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(235, 235, 235, 1), width: 2))),
      child: GestureDetector(
          child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              /*Container(
                color: Color.fromRGBO(200, 200, 200, 1),
                margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                width: 100,
                height: 100,
              ),*/
              Expanded(
                child: Container(
                  width: usableWidth,
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(title, style: titleStyle),
                        alignment: Alignment.topLeft,
                        height: 60,
                      ),
                      Container(
                        child: Text(descriptionText,
                            style: descriptionStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3),
                        alignment: Alignment.topLeft,
                        height: 55,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(author, style: subTextStyle),
                ),
                Container(
                  child: Text(date, style: subTextStyle),
                )
              ],
            ),
            margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
          )
        ],
      ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => ArticleDetail(article))),
      ),
    );
  }
}

class ArticleDetail extends StatelessWidget {
  ArticleDetail(this.article);

  final article;

  @override
  Widget build(BuildContext context) {
    var htmlSite = """<h1>${article['title']}</h1><br><br> ${castBase64ToHTML(article['body'])}""";


    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ListView(
          children: <Widget>[Html(data: htmlSite)],
        ),
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      ),
    );
  }

  String castBase64ToHTML(String text) {
    return utf8.decode(base64Decode(text.replaceAll('\n', '')));
  }
}
