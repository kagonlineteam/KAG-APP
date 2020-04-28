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
            child: GridView.count(
              childAspectRatio: 0.9,
              crossAxisCount: width > 1000 ? 3 : 1,
              children: articles,
        )
        )
    );
  }

  Widget _generateRow(article) {
    var title = article['title'] == null ? "" : article['title'];
    var descriptionText = article['preview'] == null ? "" : article['preview'];

    return
      Container(
        margin: EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                article['files'] != [] ? LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return  Container(child: Image(image: NetworkImage("https://apiv2.kag-langenfeld.de/files/" + article['files']['id']), width: constraints.maxWidth));
                  },
                ) : Container(),
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
                            descriptionText != "" ? Container(
                              child: Text(descriptionText,
                                  style: descriptionStyle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3),
                              alignment: Alignment.topLeft,
                              height: 55,
                            ) : Container()
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ArticleDetail(article['id']))),
          ),
          margin: EdgeInsets.fromLTRB(0, 5, 0, 3),
        ),
      );
  }
}

class ArticleDetail extends StatefulWidget {
  ArticleDetail(this.article);

  final String article;

  @override
  State<StatefulWidget> createState() {
    return new ArticleDetailState(article);
  }

}

class ArticleDetailState extends State<ArticleDetail> {
  ArticleDetailState(this.article);

  final String article;
  Widget content = Center(child: Text("Bitte warten.\n Der Artikel wird geladen!"),);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ListView(
          children: <Widget>[content, ],
        ),
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      ),
    );
  }

  String decodeBase64(String text) {
    return utf8.decode(base64Decode(text.replaceAll('\n', '')));
  }

  @override
  void initState() {
    super.initState();
    loadArticle();
  }

  Future<void> loadArticle() async {
    var request = await KAGApp.api.getAPIRequest(APIAction.GET_ARTICLE);
    var response = await request.getArticle(article);
    if (response == null) return;
    var articleContent = jsonDecode(response)['entity'];
    var htmlData = """<h1>${articleContent['title']}</h1><br><br> ${decodeBase64(articleContent['body'])}""";
    setState(() {
      content = Html(data: htmlData);
    });
  }

}
