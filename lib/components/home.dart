import 'dart:io';

import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_helpers.dart';
import '../api/api_models.dart';
import 'helpers.dart';
import 'menu.dart';
import 'terminlist.dart';

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
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(10),
            child: MaterialButton(
              child: Image.asset("assets/atrium.png", width: isTablet ? 200 : 130),
              onPressed: () async {
                if (await canLaunch(
                    "moodlemobile://atrium.kag-langenfeld.de")) {
                  launch("moodlemobile://atrium.kag-langenfeld.de");
                } else {
                  launch("https://atrium.kag-langenfeld.de");
                }
              },
            )
        )
      ],
    );
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
        kIsWeb || Platform.isMacOS ?
        StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            var data = 0;
            if (snapshot.hasData) data = snapshot.data;
            return Text(data.toString(), style: TextStyle(fontSize: isTablet ? 50 : 35));
          },
        )
            : FlipPanel<int>.stream(
          itemStream: stream,
          itemBuilder: (context, value) => Container(
            // The width has to be calculated like this to fit on mobile and tablet. But there should be a better way I do not know.
            width: isTablet ? MediaQuery.of(context).size.width / 3 / 7 : MediaQuery.of(context).size.width / 7,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                addLeadingZero(value),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          initValue: 0,
        ),
        Text(abbreviation)
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