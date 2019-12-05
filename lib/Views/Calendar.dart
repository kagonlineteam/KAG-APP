import 'dart:ffi';

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
    var width = MediaQuery.of(context).size.width;
    usableWidth = width - 132;

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Termine",
                      style: TextStyle(
                          fontSize: 30,
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
        )));
  }

  Widget _generateRow(entry) {
    var dateOne     = new DateTime.fromMillisecondsSinceEpoch(entry['start'] * 1000);
    var dateTwo = new DateTime.fromMillisecondsSinceEpoch(entry['stop'] * 1000);
    var dateOneText = "${betterNumbers(dateOne.day)}.${betterNumbers(
        dateOne.month)}.";
    var dateTwoText = "${betterNumbers(dateTwo.day)}.${betterNumbers(
        dateTwo.month)}.";

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(235, 235, 235, 1), width: 2))),
      child: GestureDetector(
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
                    child: Text(entry['title'], style: titleStyle),
                    alignment: Alignment.topLeft,
                    height: 40,
                  ),
                  Container(
                    child: Text(getShortedLongDescription(entry['description']),
                        style: descriptionStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2),
                    alignment: Alignment.topLeft,
                    height: 50,
                  )
                ],
              ),
            )
          ],
        ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => CalendarDetail(entry))),
      ),
    );
  }

  Future loadEntries() async {
    var entriesRequest = await KAGApp.api.getAPIRequest(APIAction.GET_CALENDAR);
    if (entriesRequest != null) {
      final entries = await entriesRequest.getCalendarEntriesSoon(page);
      var entryRows = List<Widget>.from(rows);
      entries.forEach((entry) => entryRows.add(_generateRow(entry)));
        setState(() {
          rows = entryRows;
        }
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  String getShortedLongDescription(String text) {
    if (text == null) return "";
    if (text.length > 300) {
      return text.substring(0, 300) + "...";
    } else {
      return text;
    }
  }

  String betterNumbers(int originalNumber) {
    if (originalNumber < 10) {
      return "0$originalNumber";
    }
    return "$originalNumber";
  }
}

class CalendarDetail extends StatelessWidget {
  CalendarDetail(this.entry);

  final entry;
  static const dateStyle        = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle       = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 1);
  static const tagStyle         = const TextStyle(fontSize: 16, color: Colors.white);
  static const timeStyle        = const TextStyle(fontSize: 16, color: Colors.white);
  static const descriptionStyle = const TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    var title = entry['title'];

    DateTime dateObjectOne = DateTime.fromMillisecondsSinceEpoch(entry['start'] * 1000);
    DateTime dateObjectTwo = DateTime.fromMillisecondsSinceEpoch(
        entry['stop'] * 1000);

    var dateOne = "${betterNumbers(dateObjectOne.day)}.${betterNumbers(
        dateObjectOne.month)}.";
    var dateTwo = "${betterNumbers(dateObjectTwo.day)}.${betterNumbers(
        dateObjectTwo.month)}.";
    var timeOne = "${betterNumbers(dateObjectOne.hour)}:${betterNumbers(dateObjectOne.minute)} Uhr";
    var timeTwo = "${betterNumbers(dateObjectTwo.hour)}:${betterNumbers(dateObjectTwo.minute)} Uhr";

    var description = entry['description'];
    var tagStrings  = entry['tags'];

    DateTime creationObjectDate = DateTime.fromMillisecondsSinceEpoch(
        entry['created'] * 1000);
    DateTime changeObjectDate = DateTime.fromMillisecondsSinceEpoch(
        entry['changed'] * 1000);

    var creationDate  = "Erstellt am: ${creationObjectDate.day}.${creationObjectDate.month}.${creationObjectDate.year}";
    var editDate      = "Geändert am: ${changeObjectDate.day}.${changeObjectDate.month}.${changeObjectDate.year}";
    var createdBy     = "Erstellt von: ${entry['author']}";

    List<Widget> tags = [];

    for (String tagString in tagStrings) {
      tags.add(createTag(tagString));
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: Text(
                    title,
                    style: titleStyle,
                  ),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  alignment: Alignment.centerLeft,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text(
                              dateOne,
                              style: dateStyle,
                            ),
                            Text(
                              timeOne,
                              style: timeStyle,
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
                              dateTwo,
                              style: dateStyle,
                            ),
                            Text(
                              timeTwo,
                              style: timeStyle,
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
                ),
                Container(
                  child: Row(
                    children: tags,
                  ),
                  margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
                ),
                Container(
                  child: Text(
                    description == null ? "" : description,
                    style: descriptionStyle,
                    maxLines: 5,
                  ),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  alignment: Alignment.topLeft,
                ),
              ],
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(creationDate, style: descriptionStyle),
                    alignment: Alignment.centerLeft,
                  ),
                  Container(
                    child: Text(editDate, style: descriptionStyle),
                    alignment: Alignment.centerLeft,
                  ),
                  Container(
                    child: Text(createdBy, style: descriptionStyle),
                    alignment: Alignment.centerLeft,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            )
          ],
        ),
      )),
    );
  }

  Widget createTag(String title) {
    return Container(
      child: Container(
        child: Text(
          title,
          style: tagStyle,
        ),
        margin: EdgeInsets.fromLTRB(10, 2, 10, 2),
      ),
      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      decoration: BoxDecoration(
          color: Color.fromRGBO(47, 109, 29, 1),
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
  }

  String betterNumbers(int originalNumber) {
    if (originalNumber < 10) {
      return "0$originalNumber";
    }
    return "$originalNumber";
  }
}
