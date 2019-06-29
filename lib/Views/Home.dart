import 'package:flutter/material.dart';
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
  int holiday;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    TextStyle countdownNumbers = new TextStyle(fontSize: 40);

    return new SafeArea(
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(weeks, style: countdownNumbers),
                  Text(days, style: countdownNumbers),
                  Text(hours, style: countdownNumbers),
                  Text(minutes, style: countdownNumbers),
                  Text(seconds, style: countdownNumbers)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[Text("w"), Text("d"), Text("h"), Text("m"), Text("s")],
              )
            ],
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
      print(entry);
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
}
