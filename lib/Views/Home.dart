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
  String weeks = "", days = "", hours = "", minutes = "", seconds = "";
  String date = "", title = "", description = "";
  int holiday;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    TextStyle countdownNumbers = new TextStyle(fontSize: 40);
    TextStyle eventText = new TextStyle(fontSize: 25);
    TextStyle eventDescriptionText = new TextStyle(fontSize: 18);

    return new SafeArea(
      child: Column(
        children: <Widget>[
          Row(
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
          Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Material(
                        child: Text(date, style: countdownNumbers),
                        color: Colors.green,
                        borderRadius:
                            BorderRadiusDirectional.all(Radius.circular(10)),
                      ),
                    ),
                    Text(title, style: eventText)
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(description, style: eventDescriptionText)
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future _load() async {
    var request = await KAGApp.api.getAPIRequest(APIAction.GET_CALENDAR);
    request.getHolidayUnixTimestamp().then((timestamp) {
      holiday = timestamp;
    });
    request.getNextCalendarEntry().then((entry) {
      setState(() {
        date = formatDate(
            new DateTime.fromMillisecondsSinceEpoch(entry['start'] * 1000),
            [dd, ".", mm]);
        title = entry['title'];
        description = entry['description'];
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
      this.weeks = weeks.toString();
      this.days = days.toString();
      this.hours = hours.toString();
      this.minutes = minutes.toString();
      this.seconds = seconds.toString();
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
}
