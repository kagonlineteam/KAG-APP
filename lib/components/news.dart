import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Views/News.dart';
import '../api/api_models.dart';
import '../api/api_raw.dart' as api_raw;

class ArticleCard extends StatelessWidget {
  ArticleCard(this.article);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              ImageBox(article),
              TitleBox(article)
            ],
          ),
          splashColor: Color.fromRGBO(47, 109, 29, 1),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ArticleDetail(article))),
        ),
      ),
    );
  }
}

class ImageBox extends StatelessWidget {
  final Article article;

  ImageBox(this.article);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: article.hasImage,
      child: Align(
          alignment: Alignment.bottomCenter,
          child: new Container(
            height: 230,
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.center,
                    image: CachedNetworkImageProvider("${api_raw.API}files/${article.imageID}")
                )
            ),
          )
      ),
    );
  }
}

class TitleBox extends StatelessWidget {
  final Article article;
  static const titleStyle       = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5);

  TitleBox(this.article);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: Align(
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
                child: Text(article.title, style: titleStyle, textAlign: TextAlign.left)
            )
        ),
      ),
    ));
  }


}

class ArticleDetailWidget extends StatelessWidget {
  ArticleDetailWidget(this.article);

  final Article article;

  @override
  Widget build(BuildContext context) {
    var htmlData = """${article.htmlBody != null ? article.htmlBody : ""}""";
    return Scaffold(
      appBar: AppBar(
        title: Text(article.shortTitle != null && !article.shortTitle.isEmpty ? article.shortTitle : article.title),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[Html(data: htmlData, onLinkTap: launch)],
        ),
        padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
      ),
    );
  }

}