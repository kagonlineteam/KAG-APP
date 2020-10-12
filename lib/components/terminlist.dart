import 'package:flutter/material.dart';

import '../Views/Calendar.dart';
import '../api/api_helpers.dart';
import '../api/api_models.dart';

// Creates the Date Widget on the left
class DateWidget extends StatelessWidget {
  DateWidget(Termin termin):
      dateText = "${addLeadingZero(termin.startDatetime.day)}.${addLeadingZero(termin.startDatetime.month)}";
  static const dateStyle = const TextStyle(fontSize: 20, color: Colors.white);

  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme
          .of(context)
          .primaryColor,
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
        leading:DateWidget(termin),
        title: Text(termin.title, style: TextStyle(fontSize: 23)),
        subtitle: Text(termin.preview != null ? termin.preview : ""),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarDetail(termin))),
      );
  }

}