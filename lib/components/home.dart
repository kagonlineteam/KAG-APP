import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Views/News.dart';
import '../api/api.dart';
import '../api/api_helpers.dart';
import '../api/api_models.dart';
import 'helpers.dart';
import 'menu.dart';
import 'terminlist.dart';
import '../api/api_raw.dart' as api_raw;

/// Chooses if the Mobile or TabletWidget is needed
class SurroundingWidget extends StatelessWidget {
  const SurroundingWidget({Key key, this.child}) : super(key: key);

  final Widget child;


  @override
  Widget build(BuildContext context) {
     if (MediaQuery.of(context).size.longestSide > 1000) return _TabletPageWidget(child);
     return _BaseHomePageWidget(child);
  }

}

class _BaseHomePageWidget extends StatelessWidget {
  _BaseHomePageWidget(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child:
            Stack(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    alignment: Alignment.topLeft,
                    child: Image(
                      alignment: Alignment.topLeft,
                      image: AssetImage("assets/logo.png"),
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                    )
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: ExtraOptionsMenu(),
                )
              ],
            ),
          ),
        ),
        preferredSize: Size.fromHeight(70),
      ),
      body: SafeArea(
        child: child,
      ),
    );
  }

}

class _TabletPageWidget extends StatelessWidget {
  _TabletPageWidget(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    double screenSizeWidth = MediaQuery.of(context).size.width;
    double marginWidth = screenSizeWidth > 1200 ? screenSizeWidth / 3.5 : screenSizeWidth / 6;

    double screenSizeHeight = MediaQuery.of(context).size.height;

    return _BaseHomePageWidget(
        Container(
          child: Container(
            child: Container(
              child: child,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            ),
            color: Colors.white.withOpacity(0.85),
            margin: EdgeInsets.fromLTRB(marginWidth, screenSizeHeight / 10, marginWidth, screenSizeHeight / 6),
          ),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: new AssetImage("assets/background-main.jpg"),
                  fit: BoxFit.fill
              )
          ),
        )
    );
  }

}

class HomeList extends StatelessWidget {
  const HomeList(this.homeScreenData);

  final HomeScreenData homeScreenData;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.longestSide > 1000;

    return ListView(
      children: [
        FerienCountdown(homeScreenData, isTablet: isTablet),
        if (!homeScreenData.exams.isEmpty) splittingContainer,
        if (!homeScreenData.exams.isEmpty) ExamList(homeScreenData.exams),
        splittingContainer,
        TerminList(homeScreenData),
        splittingContainer,
        ShortcutsWidget(isTablet: isTablet),
        // Only show Impressum on web
        if (kIsWeb) splittingContainer,
        if (kIsWeb) ImpressumWidget(),
        splittingContainer,
        NewsWidget(homeScreenData),
    ],
    );
  }

}

class ShortcutsWidget extends StatelessWidget {
  ShortcutsWidget({this.isTablet = false});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Text("Shortcuts", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          height: isTablet ? 180 : 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      MaterialButton(
                        child: Image.asset("assets/atrium.png",
                            width: isTablet ? 170 : 100),
                        onPressed: () async {
                          if (await canLaunchUrl(Uri.parse(
                              "moodlemobile://atrium.kag-langenfeld.de"))) {
                            launchUrl(Uri.parse(
                                "moodlemobile://atrium.kag-langenfeld.de"));
                          } else {
                            launchUrl(
                                Uri.https("atrium.kag-langenfeld.de", ""));
                          }
                        },
                      ),
                      Text("Atrium", style: TextStyle(fontSize: 20))
                    ],
                  )),
              if (API.of(context).requests.getUserInfo().isTeacher)
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        MaterialButton(
                            child: Image.asset("assets/zulip.png",
                                width: isTablet ? 170 : 100),
                            onPressed: () async {
                              if (await canLaunchUrl(Uri.parse(
                                  "zulip://lehrer.chat.kag-langenfeld.de"))) {
                                launchUrl(Uri.parse(
                                    "zulip://lehrer.chat.kag-langenfeld.de"));
                              } else {
                                launchUrl(Uri.https(
                                    "lehrer.chat.kag-langenfeld.de", ""));
                              }
                            }),
                        Text("Lehrerchat", style: TextStyle(fontSize: 20))
                      ],
                    )),
              if (API.of(context).requests.getUserInfo().cloudConsent)
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        MaterialButton(
                            child: Image.asset("assets/nextcloud.png",
                                width: isTablet ? 170 : 100),
                            onPressed: () async {
                              if (await canLaunchUrl(Uri.parse(
                                  "nextcloud://cloud.kag-langenfeld.de"))) {
                                launchUrl(Uri.parse(
                                    "nextcloud://cloud.kag-langenfeld.de"));
                              } else {
                                launchUrl(
                                    Uri.https("cloud.kag-langenfeld.de", ""));
                              }
                            }),
                        Text("Cloud", style: TextStyle(fontSize: 20))
                      ],
                    )),
            ],
          ),
        )
      ],
    );
  }

}

class NewsWidget extends StatelessWidget {
  final HomeScreenData homeScreenData;
  NewsWidget(this.homeScreenData, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      //color: Colors.pink,
      children: [
        Container(
          child: Text("News", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          alignment: Alignment.centerLeft,
        ),
          ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            return NewsListItem(homeScreenData.news[index]);
          },
        )
      ]
    );
  }
}

class NewsListItem extends StatelessWidget {
  const NewsListItem(this.news);

  final Article news;

  @override
  Widget build(BuildContext context) {
    return
    Container(
      margin: EdgeInsets.all(20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Color.fromARGB(33, 0, 0, 0),
        borderRadius: BorderRadius.all(Radius.circular(25))
      ),
      child: Column(
        children: [
          if(news.hasImage) Image(image: CachedNetworkImageProvider("https://${api_raw.API}/files/${news.imageID}")),
          ListTile(
          title: Text(news.title, style: TextStyle(fontSize: 24)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetail(news))),
          ),
        ],
      )
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
                    image: CachedNetworkImageProvider("https://${api_raw.API}/files/${article.imageID}")
                )
            ),
          )
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  ArticleCard(this.article);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
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

class FerienCountdown extends StatelessWidget {
  const FerienCountdown(this.homeScreenData, {this.isTablet = false});

  final bool isTablet;
  final HomeScreenData homeScreenData;

  @override
  Widget build(BuildContext context) {
    if (homeScreenData.countdown == null || homeScreenData.ferienDatetime.difference(DateTime.now()).isNegative) return Container();
    return Column(
      children: [
        Container(
          child: Text("Ferien-Countdown", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FerienCountdownNumber("w", Stream.periodic(Duration(seconds: 1), (i) => homeScreenData.ferienDatetime.difference(DateTime.now()).inDays ~/ 7).asBroadcastStream(), isTablet: isTablet),
              FerienCountdownNumber("d", Stream.periodic(Duration(seconds: 1), (i) => homeScreenData.ferienDatetime.difference(DateTime.now()).inDays % 7).asBroadcastStream(), isTablet: isTablet),
              FerienCountdownNumber("h", Stream.periodic(Duration(seconds: 1), (i) => homeScreenData.ferienDatetime.difference(DateTime.now()).inHours % 24).asBroadcastStream(), isTablet: isTablet),
              FerienCountdownNumber("m", Stream.periodic(Duration(seconds: 1), (i) => homeScreenData.ferienDatetime.difference(DateTime.now()).inMinutes % 60).asBroadcastStream(), isTablet: isTablet),
              FerienCountdownNumber("s", Stream.periodic(Duration(seconds: 1), (i) => homeScreenData.ferienDatetime.difference(DateTime.now()).inSeconds % 60).asBroadcastStream(), isTablet: isTablet),
            ],
          ),
          margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
        )
      ],
    );
  }

}

class FerienCountdownNumber extends StatelessWidget {
  FerienCountdownNumber(this.abbreviation, this.stream, {this.isTablet});

  final Stream stream;
  final String abbreviation;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: isTablet ? 90 : 60,
          alignment: Alignment.center,
          child: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              var data = 0;
              if (snapshot.hasData) data = snapshot.data;
              return Text(data.toString(), style: TextStyle(fontSize: isTablet ? 50 : 35));
            },
          )
        ),
        Text(abbreviation, style: TextStyle(fontSize: isTablet ? 25 : 10))
      ],
    );
  }

}

class TerminList extends StatelessWidget {
  TerminList(this.homeScreenData);

  final HomeScreenData homeScreenData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Text("Die nächsten Termine", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          alignment: Alignment.centerLeft,
        )
      ]..addAll(homeScreenData.termine.map((termin) => TerminWidget(termin))),
    );
  }

}

final DateFormat formatter = DateFormat('dd.MM');

class ExamList extends StatelessWidget {
  ExamList(this._examList);

  final List<Exam> _examList;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      Container(
        child: Text("Die nächsten Klausuren", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        alignment: Alignment.centerLeft,
      ),
      Container(
        child: Text("Beachte die Aushänge in der Schule.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        alignment: Alignment.centerLeft,
      )
    ];
    items.addAll(_examList.map((exam) => ListTile(
      title: Text("${exam.course}", style: TextStyle(fontSize: 20)),
      subtitle: Text("${exam.date != null ? formatter.format(exam.date) : "Fehlerhaftes Datum"} ${exam.stunde}. Stunde", style: TextStyle(fontSize: 14)),
      leading: Icon(Icons.school_outlined),
    )));
    return Column(
      children: items,
    );
  }


}

class ImpressumWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MaterialButton(
          child: Text("Impressum"),
          onPressed: () async {
            Article article = await API.of(context).requests.getArticle("mz8Ohncn3OiFJPRfhwsGr");
            Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetail(article)));
          },
        ),
        MaterialButton(
          child: Text("Datenschutz"),
          onPressed: () async {
            Article article = await API.of(context).requests.getArticle("6m90o7IQw3UGhxaoD9g3GB");
            Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetail(article)));
          },
        )
      ],
    );
  }
}