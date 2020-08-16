import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Views/RPlan.dart';

class ListViewDay extends StatelessWidget {
  ListViewDay(this.day);

  final DayWidget day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day.date, style: TextStyle(fontSize: 40)),
        day
      ],
    );
  }
}

class DayWidget extends StatelessWidget {

  final List<Widget> lessons;
  final String date;

  const DayWidget({Key key, this.lessons, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var row = lessons;

    if (MediaQuery.of(context).size.width >= 1000) {
      row.insert(0, DataTableHeader(isFullPlan: RPlan.of(context).hasTeacherPlan));
    }

   return Column(
     children: row,
   );
  }

}

class Lesson extends StatelessWidget {
  Lesson(this.lesson);

  final dynamic lesson;

  static const normalText   = TextStyle(fontSize: 20);
  static const bigText      = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double elementWidth = (width - 60) / 3;
    double elementHeight = 25;


    if (width < 1000) {
      var bottomLeftText = "";
      var bottomCenterText = lesson['art'];
      var bottomRightText = "";

      if (lesson['lehrer'] != null || lesson['v_lehrer'] != null) {
        if (lesson['lehrer'] != null) bottomLeftText = lesson['lehrer'];
        if (lesson['v_lehrer'] != null) bottomLeftText += " -> ${lesson['v_lehrer']}";
        bottomCenterText = "";
        bottomRightText = lesson['art'];
      }

      return new Container(
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Color.fromRGBO(235, 235, 235, 1), width: 2)
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: elementWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: elementWidth,
                          height: elementHeight,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(lesson['klasse'],
                              style: bigText, textAlign: TextAlign.left),
                        ),
                        Container(
                          width: elementWidth,
                          height: elementHeight,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(bottomLeftText,
                              style: normalText, textAlign: TextAlign.left),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: elementWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: elementWidth,
                          height: elementHeight,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(lesson['fach'],
                              style: bigText, textAlign: TextAlign.center),
                        ),
                        Container(
                          width: elementWidth,
                          height: elementHeight,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(bottomCenterText,
                              style: normalText, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: elementWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: elementWidth,
                          height: elementHeight,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(lesson['stunde'],
                              style: bigText, textAlign: TextAlign.right),
                        ),
                        Container(
                          width: elementWidth,
                          height: elementHeight,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(bottomRightText,
                              style: normalText, textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
      );
    } else {
      var row = [
        _DataTableEntry(lesson['klasse']),
        _DataTableEntry(lesson['fach']),
        _DataTableEntry(lesson['stunde']),
        _DataTableEntry(lesson['v_raum'])
      ];

      if (lesson['lehrer'] != null || lesson['v_lehrer'] != null) {
        row.add(_DataTableEntry(lesson['lehrer']));
        row.add(_DataTableEntry(lesson['v_lehrer']));
      }

      row.add(_DataTableEntry(lesson['art']));
      row.add(_DataTableEntry(lesson['infos']));

      return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
          child:Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            padding: EdgeInsets.only(top: 3, bottom: 3),
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor)
            ),
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row,
            ),
          )
      );
    }
  }
}

class DataTableHeader extends StatelessWidget {
  DataTableHeader({this.isFullPlan=false});

  final bool isFullPlan;

  @override
  Widget build(BuildContext context) {
    var header = [
      _DataTableEntry("Klasse", bold: true),
      _DataTableEntry("Kurs", bold: true),
      _DataTableEntry("Stunde", bold: true),
      _DataTableEntry("V-Raum", bold: true)
    ];

    if (isFullPlan) {
      header.add(_DataTableEntry("Lehrer", bold: true));
      header.add(_DataTableEntry("V-Lehrer", bold: true));
    }

    header.add(_DataTableEntry("Art", bold: true));
    header.add(_DataTableEntry("Infos", bold: true));

    return Container(
      margin: EdgeInsets.only(left: 5, right: 5, top: 10),
      padding: EdgeInsets.only(top: 3, bottom: 3),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor)
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: header,
      ),
    );
  }


}

class _DataTableEntry extends StatelessWidget {
  _DataTableEntry(this.entry, {this.bold=false});

  final String entry;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                right: BorderSide(color: Theme.of(context).primaryColor)
            )
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Align(
            alignment: Alignment.center,
            child: Text(entry != null ? entry : "", style: TextStyle(fontSize: 25, fontWeight: bold ? FontWeight.bold : FontWeight.normal),),
          ),
        ),
      ),
    );
  }
}

class TeacherKuerzelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: RPlan.of(context).hasTeacherPlan,
      child: Padding(
        padding: EdgeInsets.all(10),
          child: RaisedButton(
              onPressed: () => _showFilterOptions(context),
              child: Text(
                "Filtern",
                style: TextStyle(color: Colors.white),)
          )
      )
    );
  }

  Future _showFilterOptions(BuildContext context) async {
    TextEditingController teacher = TextEditingController(text: RPlan.of(context).searchedTeacher);
    showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: CupertinoAlertDialog(
          content: Column(
            children: <Widget>[
              Container(
                child: CupertinoTextField(
                  placeholder: "Kürzel",
                  placeholderStyle:
                  TextStyle(color: Color.fromRGBO(150, 150, 150, 1)),
                  controller: teacher,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color.fromRGBO(47, 109, 29, 1)))),
                ),
              ),
              Container(
                child: Text(
                  "Bitte geben Sie ihr Lehrer Kürzel ein um den Plan zu filtern.",
                ),
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              ),
            ],
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                child: Text("Abbrechen",
                    style: TextStyle(color: CupertinoColors.activeBlue)),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                SharedPreferences preferences =
                await SharedPreferences.getInstance();
                if (teacher.text == "") {
                  RPlan.of(context).searchedTeacher = null;
                  preferences.remove(RPlan.SP_FILTER);
                } else {
                  RPlan.of(context).searchedTeacher = teacher.text;
                  preferences.setString(RPlan.SP_FILTER, RPlan.of(context).searchedTeacher);
                }
                RPlan.of(context).loadRPlan();
                Navigator.pop(context);
              },
              child: Container(
                child: Text(
                  "Anwenden",
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
              ),
            ),
          ],
        ));
  }
}
