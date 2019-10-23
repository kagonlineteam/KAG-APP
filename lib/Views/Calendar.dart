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

class CalendarDetail extends StatelessWidget {
  CalendarDetail(this.entry);

  final entry;
  static const dateStyle = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 1);
  static const tagStyle = const TextStyle(fontSize: 16, color: Colors.white);
  static const timeStyle = const TextStyle(fontSize: 16, color: Colors.white);
  static const descriptionStyle = const TextStyle(fontSize: 16);



  @override
  Widget build(BuildContext context) {

    var title = "Title";

    var dateOne = "21.10";
    var timeOne = "10:25 Uhr";
    var dateTwo = "22.10";
    var timeTwo = "12:30 Uhr";

    var description = "Description";
    var tagStrings = ["Tag1", "Tag2", "Tag3"];

    var creationDate = "Erstellt am: 11.10.19";
    var editDate = "Geändert am: 12.10.19";
    var createdBy = "Erstellt von: RJipps";

    List<Widget> tags = [];
    for (String tagString in tagStrings) {
      tags.add(createTag(tagString));
    }

    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: Text(title, style: titleStyle,),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  alignment: Alignment.centerLeft,
                ),

                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text(dateOne, style: dateStyle,),
                            Text(timeOne, style: timeStyle,)
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
                            Text(dateTwo, style: dateStyle,),
                            Text(timeTwo, style: timeStyle,)
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
                  child: Text(description, style: descriptionStyle, maxLines: 5,),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  alignment: Alignment.topLeft,
                ),
              ],
            ),

            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(creationDate),
                    alignment: Alignment.centerLeft,
                  ),

                  Container(
                    child: Text(editDate),
                    alignment: Alignment.centerLeft,
                  ),

                  Container(
                    child: Text(createdBy),
                    alignment: Alignment.centerLeft,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            )
          ],
        )
    );
  }

  Widget createTag(String title) {
    return Container(
      child: Container(
        child: Text(title, style: tagStyle,),
        margin: EdgeInsets.fromLTRB(10, 2, 10, 2),
      ),
      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      decoration: BoxDecoration(
          color: Color.fromRGBO(47, 109, 29, 1),
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
    );
  }
}