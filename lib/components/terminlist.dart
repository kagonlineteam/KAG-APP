import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Views/Calendar.dart';
import '../api/api_helpers.dart';
import '../api/api_models.dart';

// Creates the Date Widget on the left
class DateWidget extends StatelessWidget {
  DateWidget(Termin termin):
      dateText = "${addLeadingZero(termin.startDatetime.day)}.${addLeadingZero(termin.startDatetime.month)}";
  static const dateStyle = const TextStyle(fontSize: 24, color: Colors.white);

  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme
          .of(context)
          .colorScheme
          .primary,
      child: Center(
        child: Container(
          child: Text(dateText, style: dateStyle),
        ),
      ),
      width: 100,
    );
  }
}

// Creates the row/tile
class TerminWidget extends StatelessWidget {
  const TerminWidget(this.termin);

  final Termin termin;

  @override
  Widget build(BuildContext context) {
    return
      ListTile(
        leading: DateWidget(termin),
        title: Text(termin.title, style: TextStyle(fontSize: 24)),
        subtitle: Text(termin.preview != null ? termin.preview : ""),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarDetail(termin))),
      );
  }

}

class AdvancedDayWidget extends StatelessWidget {

  static const dateStyle = const TextStyle(fontSize: 25, color: Colors.white);
  static const timeStyle = const TextStyle(fontSize: 16, color: Colors.white);

  AdvancedDayWidget(Termin termin):
      startDate = "${addLeadingZero(termin.startDatetime.day)}.${addLeadingZero(termin.startDatetime.month)}.",
      stopDate  = "${addLeadingZero(termin.stopDatetime.day)}.${addLeadingZero(termin.stopDatetime.month)}.",
      startTime = "${addLeadingZero(termin.startDatetime.hour)}:${addLeadingZero(termin.startDatetime.minute)} Uhr",
      stopTime  = "${addLeadingZero(termin.stopDatetime.hour)}:${addLeadingZero(termin.stopDatetime.minute)} Uhr",
      allDay    = termin.stopDatetime.difference(termin.startDatetime).inMilliseconds == (1000 * 60 * 60 * 24) - 1 ||
                  termin.stopDatetime.difference(termin.startDatetime).inMilliseconds == (1000 * 60 * 60 * 24) - 1000;

  final String startDate, startTime, stopDate, stopTime;
  final bool allDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  startDate,
                  style: dateStyle,
                ),
                Visibility(
                  visible: !allDay,
                  child: Text(
                    startTime,
                    style: timeStyle,
                  ),
                )
              ],
            ),
            margin: EdgeInsets.fromLTRB(20, 10, 0, 10),
          ),
          Container(
            child: Image.asset("assets/arrow_horizontal.png"),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  stopDate,
                  style: dateStyle,
                ),
                Visibility(
                  visible: !allDay,
                  child: Text(
                    stopTime,
                    style: timeStyle,
                  ),
                )
              ],
            ),
            margin: EdgeInsets.fromLTRB(0, 10, 20, 10),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      height: 70,
      color: Color.fromRGBO(47, 109, 29, 1),
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
    );
  }


}

class CalendarDetailWidget extends StatelessWidget {
  static const titleStyle = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 1);

  CalendarDetailWidget(this.termin);

  final Termin termin;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Container(
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        termin.title,
                        style: titleStyle,
                      ),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      alignment: Alignment.centerLeft,
                    ),
                    AdvancedDayWidget(termin),
                    Visibility(
                      visible: termin.hasDescription,
                      child: Container(
                        child: Html(data: (termin.hasDescription ? termin.description : "").replaceAll('\n', ''), onLinkTap: _launch),
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        alignment: Alignment.topLeft,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  static void _launch(String url) {
    launchUrl(Uri.parse(url));
  }
}