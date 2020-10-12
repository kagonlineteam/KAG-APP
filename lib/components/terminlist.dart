import 'package:flutter/material.dart';

import '../Views/Calendar.dart';
import '../api/api_helpers.dart';
import '../api/api_models.dart';

// Creates the Date Widget on the left
class DateWidget extends StatelessWidget {
  DateWidget(Termin termin):
      dateOneText = "${addLeadingZero(termin.startDatetime.day)}.${addLeadingZero(termin.startDatetime.month)}",
      dateTwoText = "${addLeadingZero(termin.stopDatetime.day)}.${addLeadingZero(termin.stopDatetime.month)}";

  static const dateStyle = const TextStyle(fontSize: 20, color: Colors.white);

  final String dateOneText, dateTwoText;

  @override
  Widget build(BuildContext context) {
    if (dateOneText == dateTwoText) {
      return Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Container(
            child: Text(dateOneText, style: dateStyle),
          ),
        ),
        width: 100,
      );
    }
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(dateOneText, style: dateStyle),
              ),
              Container(
                child: Image.asset("assets/arrow.png"),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(dateTwoText, style: dateStyle),
              )
            ],
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
        leading:DateWidget(termin),
        title: Text(termin.title, style: TextStyle(fontSize: 23)),
        subtitle: Text(termin.preview != null ? termin.preview : ""),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarDetail(termin))),
      );
  }

}