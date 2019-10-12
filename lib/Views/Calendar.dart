import 'package:flutter/material.dart';
import 'package:kag/api.dart';

import '../main.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CalendarState();
  }

}


class CalendarState extends State {

  static const dateStyle = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 1);
  static const descriptionStyle = const TextStyle(fontSize: 15);
  var usableWidth = 0.0;
  var page = 0;
  var rows = <Widget>[];

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    usableWidth = width - 132;

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Termine",
                      style: TextStyle(fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            )
          ],
        ),
        body: SafeArea(
            child: ListView(
              children: rows,
            )
        )
    );
  }

  Widget _generateRow(int start, int end, String titleText, String descriptionText) {
    var dateOne         = new DateTime.fromMillisecondsSinceEpoch(start * 1000);
    var dateTwo         = new DateTime.fromMillisecondsSinceEpoch(end * 1000);
    var dateOneText     = "${dateOne.day}.${dateOne.month}";
    var dateTwoText     = "${dateTwo.day}.${dateTwo.month}";

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  width: 2
              )
          )
      ),
      child: Row(
        children: <Widget>[
          Container(
            color: Color.fromRGBO(47, 109, 29, 1),
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            width: 100,
            height: 100,
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

          ),
          Container(
            height: 100,
            width: usableWidth,
            margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(titleText, style: titleStyle),
                  alignment: Alignment.topLeft,
                  height: 40,
                ),
                Container(
                  child: Text(descriptionText,
                      style: descriptionStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2
                  ),
                  alignment: Alignment.topLeft,
                  height: 50,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future loadEntries() async {
    var entriesRequest = await KAGApp.api.getAPIRequest(APIAction.GET_CALENDAR);
    if (entriesRequest != null) {
      final entries = await entriesRequest.getCalendarEntriesSoon(page);
      var entryRows = List<Widget>.from(rows);
      entries.forEach((entry) => entryRows.add(_generateRow(entry['start'], entry['end'], entry['title'], getShortedLongDescription(entry['description']))));
      setState(() {
        rows = entryRows;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  String getShortedLongDescription(String text) {
    if (text.length > 300) {
      return text.substring(0,300) + "...";
    } else {
      return text;
    }
  }

}