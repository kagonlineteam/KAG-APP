import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'dart:async';

import '../main.dart';
import '../api.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  static const TextStyle eventDate =
      const TextStyle(fontSize: 35, color: Colors.white);
  static const TextStyle eventTitle =
      const TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const TextStyle eventDescriptionText = const TextStyle(fontSize: 18);

  String weeks = "", days = "", hours = "", minutes = "", seconds = "";
  String date = "", title = "", description = "";
  int holiday;
  Timer timer;

  List<Container> calendarEntries = [];

  @override
  Widget build(BuildContext context) {
    TextStyle countdownNumbers = new TextStyle(fontSize: 40);
    TextStyle titleStyle =
        new TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

    return new SafeArea(
      child: Column(
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
                Column(
                  children: <Widget>[
                    Text(weeks, style: countdownNumbers),
                    Text("w")
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(days, style: countdownNumbers),
                    Text("d")
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(hours, style: countdownNumbers),
                    Text("h")
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(minutes, style: countdownNumbers),
                    Text("m")
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(seconds, style: countdownNumbers),
                    Text("s")
                  ],
                )
              ],
            ),
            margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
          ),

          //Appointments
          Container(
            child: Text("Die nächsten Termine", style: titleStyle),
            margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
            alignment: Alignment.centerLeft,
          ),
          Column(
            children: calendarEntries,
          )
        ],
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
            entry['description']);
      });
    });
  }

  void calculateTimer() {
    if (holiday == null) return;
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

  void addCalendarEntry(String date, String title, String description) {
    setState(() {
      calendarEntries.add(Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                  child: Text(title, style: eventTitle, overflow: TextOverflow.ellipsis,),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                      child: Text(getSubString(description), style: eventDescriptionText),
                      margin: EdgeInsets.fromLTRB(0, 10, 10, 0)),
                )
              ],
            )
          ],
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

  String getSubString(String text) {
    String returnText = "";
    if (text.length > 50) {
      returnText = text.substring(0,50);
    } else {
      returnText = text.substring(0, text.length-1);
    }

    if (returnText.compareTo(text) != 0) {
      returnText += "...";
    }
    return returnText;
  }
}
