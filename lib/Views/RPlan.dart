import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';
import '../api/api_models.dart' as api_models;
import '../components/helpers.dart';
import '../components/rplan_components.dart';
import '../components/rplan_structure.dart';


class RPlanViewWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return RPlan();
  }
}

class RPlan extends State {
  static const SP_FILTER  = "RPlan_filter";

  bool hasTeacherPlan = false;
  int _loaded = -1; // -2 = Error, -1 = Not Preloaded, 0 = Not loaded, 3 = loaded
  String searchedTeacher;

  List<DayWidget> _days;

  @override
  Widget build(BuildContext context) {
    if (_loaded == 3) {
      bool isDesktop = kIsWeb && MediaQuery.of(context).size.width > 1000;
      return isDesktop ? RPlanListView(_days) : RPlanTabBar(_days);
    } else if (_loaded  == -2) {
      return ErrorTextHolder("Der Vertretungsplan ist momentan nicht verfügbar.", barTitle: "VPlan");
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("VPlan"),
        ),
        body: WaitingWidget(),
      );
    }
  }
  
  static RPlan of(BuildContext context) {
    return context.findAncestorStateOfType<RPlan>();
  }

  @override
  void initState() {
    super.initState();
    hasTeacherPlan = API.of(context).requests.isTeacher();
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
    try {
      api_models.VPlan vplan = await API.of(context).requests.getVPlan(searchedTeacher, day);

      var newLessons = <Widget>[];

      newLessons.addAll(_preProcessLessonData(vplan));

      setState(() {
        _days.add(DayWidget(
            lessons: newLessons,
            dateTime: vplan.date,
            pdfFile: vplan.file
        ));
        _days.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        // Only set to loaded if really loaded
        if (_loaded != 3  && _loaded != -2) _loaded++;
      });
    } on Exception catch (_) {
      setState(() {
        _loaded = -2;
      });
    }
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
              vplan.lessons[a].v_lehrer == vplan.lessons[b].v_lehrer &&
              vplan.lessons[a].stunde.length == 1 &&
              vplan.lessons[b].stunde.length == 1 &&
              int.tryParse(vplan.lessons[a].stunde) != null &&
              int.tryParse(vplan.lessons[b].stunde) != null &&
              int.tryParse(vplan.lessons[b].stunde) != 3 &&
              int.tryParse(vplan.lessons[b].stunde) != 5 &&
              int.tryParse(vplan.lessons[a].stunde) + 1 == int.tryParse(vplan.lessons[b].stunde)
          ) {
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
    if (first == null && second == null) {
      return (Container());
    }

    String arrow = second != null && second.isEmpty ? "" : "->";

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
                    child: Text(first != null ? first : "-", style: textStyle, textAlign: TextAlign.left),
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
                    child: Text(second != null ? second : "-", style: textStyle, textAlign: TextAlign.right),
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
    return "${lesson.klasse != null ? lesson.klasse : ""}${lesson.klasse != null && lesson.fach != null ? " - " : ""}${lesson.fach != null ? lesson.fach : ""}";
  }

  String getTeacherText(String teacher, String vTeacher) {
    if ((teacher == null || teacher.isEmpty) && (vTeacher == null || vTeacher.isEmpty)) {
      return "";
    }
    return "Lehrer";
  }
}