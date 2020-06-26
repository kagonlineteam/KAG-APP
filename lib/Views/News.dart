import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../main.dart';


class News extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewsState();
  }
}

class NewsState extends State<News> {
  static const titleStyle       = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5);
  num usableWidth               = 0.0;
  int page = 0;
  List<Widget> articles = [];
  ScrollController controller = ScrollController();


  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.atEdge) {
        if (controller.position.pixels != 0) {
          page++;
          _load();
        }
      }
    });
    _load();
  }




  Future _load() async {
    var request = await KAGApp.api.getAPIRequest(APIAction.GET_ARTICLE);
    var response = await request.getArticles(page: page);
    if (response == null) return;
    var entries = jsonDecode(response)['entities'];
    var entryRows = List<Widget>.from(articles);
    for (var entry in entries) {
      entryRows.add(await _generateRow(entry));
    }
    setState(() {
      articles = entryRows;
    });
  }


  @override
  Widget build(BuildContext context) {

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
              controller: controller,
              children: [
                Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Wrap(
                    children: articles,
                  ),
                )],

            )

        )
    );
  }

  Widget _generateRow(article) {
    var title = article['title'] == null ? "" : article['title'];

    return
      Container(
        width: 400,
        margin: EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 1,
          child: InkWell(
            child: Stack(
              children: [
                article['files'] != [] ? Align(
                    alignment: Alignment.bottomCenter,
                    child: new Container(
                      height: 230,
                      decoration: new BoxDecoration(
                          image: new DecorationImage(
                              fit: BoxFit.fitWidth,
                              alignment: FractionalOffset.center,
                              image: CachedNetworkImageProvider("https://apiv2.kag-langenfeld.de/files/${article['files']['id']}")
                          )
                      ),
                    )
                ) : Container(),
                Positioned.fill(child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color.fromRGBO(47, 47, 47, 0), Color.fromRGBO(47, 47, 47, 0.3),  Color.fromRGBO(47, 47, 47, 0.6), Color.fromRGBO(47, 47, 47, 0.8)],
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                            child: Text(title, style: titleStyle, textAlign: TextAlign.left)
                        )
                    ),
                  ),
                ))

              ],
            ),
            splashColor: Color.fromRGBO(47, 109, 29, 1),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ArticleDetail(article['id']))),
          ),
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
      content = Html(data: htmlData, onLinkTap: launch,);
    });
  }

}
