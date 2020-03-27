import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kag/Views/Calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../main.dart';
import 'Calendar.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  static const TextStyle  eventDate            = const TextStyle(fontSize: 25, color: Colors.white);
  static const TextStyle  eventTitle           = const TextStyle(fontSize: 25);
  static const TextStyle  eventDescriptionText = const TextStyle(fontSize: 18);
  static const TextStyle  titleStyle           = const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle  logoStyle            = const TextStyle(fontSize: 80, color: Colors.white);
  static const BorderSide splittingBorder      = const BorderSide( color: Color.fromRGBO(47, 109, 29, 1), width: 2);
  static final Container splittingContainer    = Container(margin: EdgeInsets.fromLTRB(10, 0, 10, 0),decoration: BoxDecoration(border: Border(top: splittingBorder)));

  String weeks = "", days = "", hours = "", minutes = "", seconds = "";
  String date = "", title = "", description = "";
  int holiday;
  Timer timer;


  List<Container> calendarEntries = [];


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size.width;

    TextStyle countdownNumbers = new TextStyle(fontSize: 25);

    Widget moodleIcon;
    if (kIsWeb) {
      moodleIcon = Image.network("https://moodle.org/pluginfile.php/2840042/mod_page/content/19/Moodle-Logo-RGB.png", width: 75);
    } else {
      moodleIcon = CachedNetworkImage(
        imageUrl:
        "https://moodle.org/pluginfile.php/2840042/mod_page/content/19/Moodle-Logo-RGB.png",
        width: 75,
        fadeInDuration: Duration(seconds: 0),
      );
    }


    return new Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: Align(
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                    height: 100,
                    fit: BoxFit.fitWidth,
                  )
              ),
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        preferredSize: Size.fromHeight(110),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            //Holiday Countdown
            Container(
              child: Text("Ferien-Countdown", style: titleStyle),
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              alignment: Alignment.centerLeft,
            ),
            Container(
              child: Row(
                mainAxisAlignment: screenSize > 500 ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    margin:EdgeInsets.fromLTRB(10, 0, screenSize / 50, 0),
                    child: Column(
                      children: <Widget>[
                        Text(weeks, style: countdownNumbers),
                        Text("w")
                      ],
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.fromLTRB(0, 0, screenSize / 50, 0),
                    child: Column(
                      children: <Widget>[
                        Text(days, style: countdownNumbers),
                        Text("d")
                      ],
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.fromLTRB(0, 0, screenSize / 50, 0),
                    child: Column(
                      children: <Widget>[
                        Text(hours, style: countdownNumbers),
                        Text("h")
                      ],
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.fromLTRB(0, 0, screenSize / 50, 0),
                    child: Column(
                      children: <Widget>[
                        Text(minutes, style: countdownNumbers),
                        Text("m")
                      ],
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Column(
                      children: <Widget>[
                        Text(seconds, style: countdownNumbers),
                        Text("s")
                      ],
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
            ),
            //Appointments
            splittingContainer,
            Container(
              child: Text("Die nächsten Termine", style: titleStyle),
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              alignment: Alignment.centerLeft,
            ),
            Column(
              children: calendarEntries,
            ),
            splittingContainer,
            //Moodle
            Container(
              child: Text("Atrium (Moodle)", style: titleStyle),
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              alignment: Alignment.centerLeft,
            ),
            Container(
              child: Text(
                  "Moodle and the Moodle logo are trademarks of Moodle Pty Ltd.",
                  style: TextStyle(fontSize: 7)),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.centerLeft,
            ),
            Row(
              children: <Widget>[
                MaterialButton(
                  child: moodleIcon,
                  onPressed: () async {
                    if (await canLaunch(
                        "moodlemobile://atrium.kag-langenfeld.de")) {
                      launch("moodlemobile://atrium.kag-langenfeld.de");
                    } else {
                      launch("https://atrium.kag-langenfeld.de");
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _load() async {
    (await KAGApp.api.getAPIRequest(APIAction.GET_CALENDAR))
        .getHolidayUnixTimestamp()
        .then((timestamp) {
      holiday = timestamp;
      calculateTimer();
    });
    (await KAGApp.api.getAPIRequest(APIAction.GET_CALENDAR))
        .getNextCalendarEntries()
        .then((entries) {
      entries.forEach((entry) {
        addCalendarEntry(
            formatDate(
                new DateTime.fromMillisecondsSinceEpoch(entry['start'] * 1000),
                [dd, ".", mm]),
            entry['title'],
            entry);
      });
    });
  }

  void calculateTimer() {
    if (holiday == null) return;
    if (holiday <= new DateTime.now().millisecondsSinceEpoch ~/ 1000) {
      setState(() {
        this.weeks = betterNumber(0);
        this.days = betterNumber(0);
        this.hours = betterNumber(0);
        this.minutes = betterNumber(0);
        this.seconds = betterNumber(0);
      });
      return;
    }
    int secondsNow = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int weeks = (holiday - secondsNow) ~/ 604800;
    int days = (holiday - secondsNow - (weeks * 604800)) ~/ 86400;
    int hours =
        (holiday - secondsNow - (weeks * 604800) - (days * 86400)) ~/ 3600;
    int minutes = (holiday -
        secondsNow -
        (weeks * 604800) -
        (days * 86400) -
        (hours * 3600)) ~/
        60;
    int seconds = (holiday -
        secondsNow -
        (weeks * 604800) -
        (days * 86400) -
        (hours * 3600) -
        (minutes * 60));
    if (days < 0) days = 0;
    if (hours < 0) hours = 0;
    if (minutes < 0) minutes = 0;
    if (seconds < 0) seconds = 0;
    setState(() {
      this.weeks = betterNumber(weeks);
      this.days = betterNumber(days);
      this.hours = betterNumber(hours);
      this.minutes = betterNumber(minutes);
      this.seconds = betterNumber(seconds);
    });
  }

  Future<void> addCalendarEntry(String date, String title, entry) async {

    setState(() {
      calendarEntries.add(Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: GestureDetector(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Material(
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(text: " ", style: TextStyle(fontSize: 25)),
                          TextSpan(text: date, style: eventDate),
                          TextSpan(text: " ", style: TextStyle(fontSize: 25))
                        ]), //Text(" " + date + " ", style: eventDate)
                      ),
                      color: Color.fromRGBO(47, 109, 29, 1),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: eventTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ],
          ),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => CalendarDetail(entry))),
        ),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    timer =
    new Timer.periodic(Duration(seconds: 1), (timer) => calculateTimer());
    _load();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  String betterNumber(int number) {
    if (number.toString().length == 1) {
      return "0" + number.toString();
    }
    return number.toString();
  }

  String getShortedDescription(String text) {
    if (text == null) return "";
    if (text.length > 50) {
      return text.substring(0, 50) + "...";
    } else {
      return text;
    }
  }
}
