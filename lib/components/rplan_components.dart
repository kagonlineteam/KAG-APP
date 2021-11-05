import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Views/RPlan.dart';
import '../api/api.dart';
import '../api/api_models.dart' as api_model;

import '../dynimports/apifile/dynapifile.dart'
if (dart.library.html) '../dynimports/apifile/webapifile.dart'
if (dart.library.io) '../dynimports/apifile/mobileapifile.dart' as apifile;

class ListViewDay extends StatelessWidget {
  ListViewDay(this.day);

  final DayWidget day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Padding(
            child: Text(day.date, style: TextStyle(fontSize: 40)),
            padding: EdgeInsets.all(10),
          ),
          DownloadFileButton(day.pdfFile)
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        day
      ],
    );
  }
}

class TabViewDay extends StatelessWidget {
  TabViewDay(this.day);

  final DayWidget day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => RPlan.of(context).loadRPlan(),
        child: ListView(children: [day]),
      ),
      floatingActionButton: Visibility(
        visible: RPlan.of(context).hasTeacherPlan && day.pdfFile != null,
        child: FloatingActionButton(
          onPressed: () => apifile.openFile(context, day.pdfFile, 'application/pdf'),
          child: Icon(Icons.file_download),
        ),
      ),
    );
  }

}

class DayWidget extends StatelessWidget {

  final List<Widget> lessons;
  final DateTime dateTime;
  final String pdfFile;

  const DayWidget({Key key, this.lessons, this.dateTime, this.pdfFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lessons.length == 0) {
      if (MediaQuery.of(context).size.width <= 1000) {
        return Container(margin: const EdgeInsets.only(top: 250.0),
            alignment: Alignment.center,
            child: Text("Es gibt derzeit am $date keine Vertretungen ${API.of(context).requests.getUserInfo().useSie ? "für Sie" : "für dich"}."));
      } else {
        return Container(margin: const EdgeInsets.only(left: 12.0),
            alignment: Alignment.bottomLeft,
            child: Text("Es gibt derzeit am $date keine Vertretungen ${API.of(context).requests.getUserInfo().useSie ? "für Sie" : "für dich"}."));
      }
    }

    // If there are rows:
    var row = new List<Widget>.from(lessons);

    if (MediaQuery.of(context).size.width >= 1000) {
      row.insert(0, DataTableHeader(isFullPlan: RPlan.of(context).hasTeacherPlan));
    }

    return Column(
     children: row,
    );
  }

  // ignore: type_annotate_public_apis
  get date {
    return "${dateTime.day}.${dateTime.month}";
  }

}

class Lesson extends StatelessWidget {
  Lesson(this.lesson);

  final api_model.Lesson lesson;

  static const normalText   = TextStyle(fontSize: 20);
  static const bigText      = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 1000) {
      return MobileLesson(lesson);
    } else {
      List<_DataTableEntry> row = [];

      if (RPlan.of(context).hasTeacherPlan) {
        row.add(_DataTableEntry(lesson.v_lehrer));
        row.add(_DataTableEntry(lesson.klasse != "" ? lesson.klasse : lesson.v_klasse));
        row.add(_DataTableEntry(lesson.v_fach));
        row.add(_DataTableEntry(lesson.v_raum));
        row.add(_DataTableEntry(lesson.stunde));
        row.add(_DataTableEntry(lesson.lehrer));
        row.add(_DataTableEntry(lesson.fach));
        row.add(_DataTableEntry(lesson.raum));
        row.add(_DataTableEntry(lesson.type));
        row.add(_DataTableEntry(lesson.infos));
      } else {
        row.add(_DataTableEntry(lesson.klasse != "" ? lesson.klasse : lesson.v_klasse));
        row.add(_DataTableEntry(lesson.fach));
        row.add(_DataTableEntry(lesson.v_fach));
        row.add(_DataTableEntry(lesson.stunde));
        row.add(_DataTableEntry(lesson.v_raum));
        row.add(_DataTableEntry(lesson.type));
        row.add(_DataTableEntry(lesson.infos));
      }

      return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
          child:Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            padding: EdgeInsets.only(top: 3, bottom: 3),
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary)
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

class MobileLesson extends StatelessWidget {
  MobileLesson(this.lesson);

  final dynamic lesson;

  static const bigText      = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const normalText   = TextStyle(fontSize: 20);


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(margin: EdgeInsets.all(2)),
        InkWell(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(lesson.klasse != null ? lesson.klasse : "", style: bigText, textAlign: TextAlign.left)),
                      Expanded(child: Text(lesson.fach != null ? lesson.fach : "", style: bigText, textAlign: TextAlign.center)),
                      Expanded(child: Text(lesson.stunde != null ? lesson.stunde : "", style: bigText, textAlign: TextAlign.right))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  Container(margin: EdgeInsets.all(5)),
                  Row(
                    children: [
                      Expanded(child: Visibility(
                        visible: RPlan.of(context).hasTeacherPlan,
                        child: Text("${lesson.lehrer != null ? "${lesson.lehrer} -> " : ""}${lesson.v_lehrer == null || lesson.v_lehrer == "" ? "-" : lesson.v_lehrer}", style: normalText, textAlign: TextAlign.left),
                      )),
                      Expanded(child: Visibility(
                        visible: !RPlan.of(context).hasTeacherPlan,
                        child: Text(lesson.type, style: normalText, textAlign: TextAlign.center),
                      )),
                      Expanded(child: Visibility(
                        visible: RPlan.of(context).hasTeacherPlan,
                        child: Text(lesson.type, style: normalText, textAlign: TextAlign.right),
                      ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => RPlanDetail(lesson)))
        ),
        Container(margin: EdgeInsets.all(8), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 2)))),
      ],
    );
  }

}

class DataTableHeader extends StatelessWidget {
  DataTableHeader({this.isFullPlan=false});

  final bool isFullPlan;

  @override
  Widget build(BuildContext context) {
    List<_DataTableEntry> header = [];

    if (isFullPlan) {
      header.add(_DataTableEntry("V-Lehrer", bold: true));
      header.add(_DataTableEntry("Klasse", bold: true));
      header.add(_DataTableEntry("V-Fach", bold: true));
      header.add(_DataTableEntry("V-Raum", bold: true));
      header.add(_DataTableEntry("Stunde", bold: true));
      header.add(_DataTableEntry("Lehrer", bold: true));
      header.add(_DataTableEntry("Fach", bold: true));
      header.add(_DataTableEntry("Raum", bold: true));
      header.add(_DataTableEntry("Art", bold: true));
      header.add(_DataTableEntry("Infos", bold: true));
    } else {
      header.add(_DataTableEntry("Klasse", bold: true));
      header.add(_DataTableEntry("Fach", bold: true));
      header.add(_DataTableEntry("V-Fach", bold: true));
      header.add(_DataTableEntry("Stunde", bold: true));
      header.add(_DataTableEntry("V-Raum", bold: true));
      header.add(_DataTableEntry("Art", bold: true));
      header.add(_DataTableEntry("Infos", bold: true));
    }

    return Container(
      margin: EdgeInsets.only(left: 5, right: 5, top: 10),
      padding: EdgeInsets.only(top: 3, bottom: 3),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary)
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
                right: BorderSide(color: Theme.of(context).colorScheme.primary)
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

class DownloadFileButton extends StatelessWidget {

  final String file;

  DownloadFileButton(this.file);

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: RPlan.of(context).hasTeacherPlan && file != null,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: () => apifile.openFile(context, file, 'application/pdf'),
                child: Text(
                  "Als PDF",
                  style: TextStyle(color: Colors.white),)
            )
        )
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
          child: ElevatedButton(
              onPressed: () => _showFilterOptions(context),
              child: Text(
                "Filtern",
                style: TextStyle(color: Colors.white),)
          )
      )
    );
  }

  Future _showFilterOptions(BuildContext pageContext) async {
    TextEditingController teacher = TextEditingController(text: RPlan.of(pageContext).searchedTeacher);
    showDialog(
        context: pageContext,
        builder: (context) => CupertinoAlertDialog(
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
                  RPlan.of(pageContext).searchedTeacher = null;
                  preferences.remove(RPlan.SP_FILTER);
                } else {
                  RPlan.of(pageContext).searchedTeacher = teacher.text;
                  preferences.setString(RPlan.SP_FILTER, RPlan.of(pageContext).searchedTeacher);
                }
                RPlan.of(pageContext).loadRPlan();
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
        )
    );
  }
}
