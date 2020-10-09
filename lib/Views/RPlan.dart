import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../api/api_models.dart' as api_models;
import '../components/helpers.dart';
import '../components/rplan_components.dart';
import '../components/rplan_structure.dart';
import '../main.dart';


class RPlanViewWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return RPlan();
  }
}

class RPlan extends State {
  static const SP_FILTER  = "RPlan_filter";

  bool hasTeacherPlan = false;
  int _loaded = -1; // -1 = Not Preloaded, 0 = Not loaded, 3 = loaded
  String searchedTeacher;

  List<DayWidget> _days;

  @override
  Widget build(BuildContext context) {
    if (_loaded == 3) {
      if (_days.length == 0) {
        return ErrorTextHolder(hasTeacherPlan ?
        // Teacher Error Message
        "Es gibt keine Vertretungen für Sie. Sollte dies unerwartet sein und Sie einen Filter konfiguriert haben, so überprüfen sie bitte das eingebene Kürzel." :
        // Student Error Message
        "Es gibt keine Vertretung für dich.", barActions: [TeacherKuerzelButton()], barTitle: "VPlan");
      }
      bool isDesktop = kIsWeb && MediaQuery.of(context).size.width > 1000;
      return isDesktop ? RPlanListView(_days) : RPlanTabBar(_days);
    } else {
      return ErrorTextHolder("Der Vertretungsplan wird noch geladen.", barTitle: "VPlan");
    }
  }
  
  static RPlan of(BuildContext context) {
    return context.findAncestorStateOfType<RPlan>();
  }

  @override
  void initState() {
    super.initState();
    _loadOptions().then((value) {
        _loaded = 0;
        loadRPlan();
    });
  }

  Future _loadOptions() async {
    // Load searched Teacher
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(SP_FILTER)) {
      searchedTeacher = preferences.getString(SP_FILTER);
    }

    // Load Settings
    var groups = await KAGApp.api.requests.getGroups();
    hasTeacherPlan = (groups.contains("ROLE_LEHRER") || groups.contains("ROLE_ADMINISTRATOR"));
  }

  // Get Data
  Future loadRPlan() async{
    if (_loaded == 3) _loaded = 0;
    _days = [];
    _loadDay(0);
    _loadDay(1);
    if (hasTeacherPlan) {
      _loadDay(2);
    } else {
      _loaded++;
    }
  }

  Future _loadDay(int day) async {
    api_models.VPlan vplan = await KAGApp.api.requests.getVPlan(searchedTeacher, day);

    var newLessons = <Widget>[];

    newLessons.addAll(_preProcessLessonData(vplan));

    setState(() {
      if (!newLessons.isEmpty) {
        _days.add(DayWidget(
          lessons: newLessons,
          dateTime: vplan.date,
          pdfFile: vplan.file
        ));
      }
      _days.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      // Only set to loaded if really loaded
      if (_loaded != 3) _loaded++;
    });
  }


  List<Lesson> _preProcessLessonData(api_models.VPlan vplan) {
    List<Lesson> newLessons = [];
    if (vplan  != null && vplan.lessons.length > 0) {
      var notPrint = [];
      for (int a = 0; a < vplan.lessons.length; a++) {
        for (int b = a + 1; b < vplan.lessons.length; b++) {
          if (vplan.lessons[a].v_fach == vplan.lessons[b].v_fach &&
              vplan.lessons[a].v_raum == vplan.lessons[b].v_raum &&
              vplan.lessons[a].v_klasse ==  vplan.lessons[b].v_klasse &&
              vplan.lessons[a].klasse ==  vplan.lessons[b].klasse &&
              vplan.lessons[a].type == vplan.lessons[b].type &&
              vplan.lessons[a].fach == vplan.lessons[b].fach &&
              vplan.lessons[a].raum == vplan.lessons[b].raum &&
              vplan.lessons[a].lehrer == vplan.lessons[b].lehrer &&
              vplan.lessons[a].v_lehrer == vplan.lessons[b].v_lehrer) {
            notPrint.add(b);
            vplan.lessons[a].stunde = "${vplan.lessons[a].stunde}-${vplan.lessons[b].stunde}";
          }
        }
      }
      for (int i = 0; i < vplan.lessons.length; i++) {
        if (!notPrint.contains(i)) {
          newLessons.add(Lesson(vplan.lessons[i]));
        }
      }
    }
    return newLessons;
  }
}

// ignore: must_be_immutable
class RPlanDetail extends StatelessWidget {
  RPlanDetail(this.lesson);

  api_models.Lesson lesson;
  double width;
  static const TextStyle textStyle  = const TextStyle(fontSize: 25);
  static const TextStyle titleStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    List<Widget> widgets = [
      element("Art", lesson.type, ""),
      element("Stunde", lesson.stunde, ""),
      element("Fach", lesson.fach, lesson.v_fach),
      element("Raum", lesson.raum, lesson.v_raum),
      element("Infos", lesson.infos, ""),
    ];

    if (getTeacherText(lesson.lehrer, lesson.v_lehrer).compareTo("") != 0) {
      widgets.insert(1,
          element(getTeacherText(lesson.lehrer,
              lesson.v_lehrer),
              lesson.lehrer,
              lesson.v_lehrer));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarText()),
      ),
      body: SafeArea(
          child: ListView(
            children: <Widget>[
              Column(children: widgets)
            ],
          )
      ),
    );
  }

  Container element(String title, String first, String second) {
    if (first.compareTo("") == 0 && second.compareTo("") == 0) {
      return (Container());
    }

    String arrow = second.compareTo("") == 0 ? "" : "->";

    final container = Container(
      margin: EdgeInsets.fromLTRB(20, 15, 20, 15),
      //color: Colors.pink,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(title, style: titleStyle,
                  ),
                  width: width - 40,
                  height: 30,
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: Text(first, style: textStyle, textAlign: TextAlign.left),
                  height: 30,
                ),
                fit: FlexFit.loose
              ),
              Flexible(
                child: Container(
                    child: Text(arrow, style: textStyle, textAlign: TextAlign.center),
                    height: 30,
                  ),
                flex: 0,
              ),
              Flexible(
                child: Container(
                  child: Text(second, style: textStyle, textAlign: TextAlign.right),
                  height: 30,
                ),
                fit: FlexFit.loose
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ],
      ),
    );
    return container;
  }

  String getAppBarText() {
    String returnString = lesson.klasse;

    if (lesson.klasse != "" && lesson.fach != "") returnString += " - ";
    returnString += lesson.fach;
    return returnString;
  }

  String getTeacherText(String teacher, String vTeacher) {
    if (teacher.isEmpty && vTeacher.isEmpty) {
      return "";
    }
    return "Lehrer";
  }
}