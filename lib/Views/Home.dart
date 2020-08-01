import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_panel/flip_panel.dart';

import '../api.dart';
import '../components/menu.dart';
import '../main.dart';

import 'Calendar.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  static TextStyle  eventDate            ;
  static TextStyle  eventTitle           ;
  //static TextStyle  eventDescriptionText ;
  static TextStyle  titleStyle           ;
  //static const TextStyle  logoStyle            = const TextStyle(fontSize: 80, color: Colors.white);
  static const BorderSide splittingBorder      = const BorderSide( color: Color.fromRGBO(47, 109, 29, 1), width: 2);
  static final Container splittingContainer    = Container(margin: EdgeInsets.fromLTRB(10, 0, 10, 0),decoration: BoxDecoration(border: Border(top: splittingBorder)));
  static bool isTablet;


  int weeks = 0, days = 0, hours = 0, minutes = 0, seconds = 0;
  String date = "", title = "", description = "";
  int holiday;
  Timer timer;
  double countDownSize = 25;

  List<Container> calendarEntries = [];
  List<dynamic> rawCalendarEntries = [];


  @override
  Widget build(BuildContext context) {
    isTablet = MediaQuery.of(context).size.longestSide > 1000;
    eventDate            = TextStyle(fontSize: isTablet ? 30 : 25, color: Colors.white);
    eventTitle           = TextStyle(fontSize: isTablet ? 30 : 25);
    titleStyle           = TextStyle(fontSize: (isTablet ? 33 : 28), fontWeight: FontWeight.bold);
    countDownSize = isTablet ? 50 : 35;
    rebuildCalendarEntries();

    var screenSizeWidth = MediaQuery.of(context).size.width;
    var screenSizeHeight = MediaQuery.of(context).size.height;

    Widget moodleIcon;
    if (kIsWeb) {
      moodleIcon = Image.network("https://moodle.org/pluginfile.php/2840042/mod_page/content/19/Moodle-Logo-RGB.png", width: isTablet ? 250 : 175);
    } else {
      moodleIcon = CachedNetworkImage(
        imageUrl:
        "https://moodle.org/pluginfile.php/2840042/mod_page/content/19/Moodle-Logo-RGB.png",
        width: isTablet ? 250 : 175,
        fadeInDuration: Duration(seconds: 0),
      );
    }

    Widget content = ListView(
      children: <Widget>[
        //Holiday Countdown
        Container(
          child: Text("Ferien-Countdown", style: titleStyle),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _createFerienCountdownNumber(screenSizeWidth, "w"),
              _createFerienCountdownNumber(screenSizeWidth, "d"),
              _createFerienCountdownNumber(screenSizeWidth, "h"),
              _createFerienCountdownNumber(screenSizeWidth, "m"),
              _createFerienCountdownNumber(screenSizeWidth, "s"),
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
    );

    if (isTablet)  {
      content = Container(
        child: Container(
          child: Container(
            child: content,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          ),
          color: Colors.white,
          margin: EdgeInsets.fromLTRB(screenSizeWidth / 3, screenSizeHeight / 10, screenSizeWidth / 3, screenSizeHeight / 6),
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new AssetImage("assets/background-main.jpg"),
            fit: BoxFit.fill
          )
        ),
      );
    }

    return new Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child:
                Stack(
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        alignment: Alignment.topCenter,
                        child: Image(
                          image: AssetImage("assets/logo.png"),
                          height: 100,
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
        preferredSize: Size.fromHeight(110),
      ),
      body: SafeArea(
        child: content,
      ),
    );
  }

  Widget _createFerienCountdownNumber(double screenSizeWidth, String char, ) {
    return Column(
        children: <Widget>[
          kIsWeb ?
            Text(_getFerienValue(char).toString(), style: TextStyle(fontSize: countDownSize),)
          : FlipPanel<int>.stream(
            itemStream: Stream.periodic(
                Duration(milliseconds: 1000), (count) => _getFerienValue(char)),
            itemBuilder: (context, value) => Container(
              // The width has to be calculated like this to fit on mobile and tablet. But there should be a better way I do not know.
                width: MediaQuery.of(context).size.longestSide > 1000 ? MediaQuery.of(context).size.width / 3 / 7 : MediaQuery.of(context).size.width / 7,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    betterNumber(value),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            initValue: _getFerienValue(char),
          ),
          Text(char)
        ],
    );
  }

  int _getFerienValue(char) {
    switch (char) {
      case "w":
        return weeks;
      case "d":
        return days;
      case "h":
        return hours;
      case "m":
        return minutes;
      case "s":
        return seconds;
    }
    return 0;
  }

  void rebuildCalendarEntries() {
    calendarEntries = [];
    rawCalendarEntries.forEach((entry) {
      addCalendarEntry(
          formatDate(
              new DateTime.fromMillisecondsSinceEpoch(entry['start'] * 1000),
              [dd, ".", mm]),
          entry['title'],
          entry);
    });
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
          rawCalendarEntries = entries;
    });
  }

  void calculateTimer() {
    if (holiday == null) return;
    if (holiday <= new DateTime.now().millisecondsSinceEpoch ~/ 1000) {
      setState(() {
        this.weeks = 0;
        this.days = 0;
        this.hours = 0;
        this.minutes = 0;
        this.seconds = 0;
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
      this.weeks = weeks;
      this.days = days;
      this.hours = hours;
      this.minutes = minutes;
      this.seconds = seconds;
    });
  }

  Future<void> addCalendarEntry(String date, String title, Map<String, dynamic> entry) async {
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
                    width: 80,
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
                      overflow: TextOverflow.fade,
                    ),
                  )
                ],
              ),
            ],
          ),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => CalendarDetail(new Termin.fromJSON(entry)))),
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
      return "0${number.toString()}";
    }
    return number.toString();
  }
}
