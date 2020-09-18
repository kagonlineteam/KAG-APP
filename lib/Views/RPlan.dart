import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../api.dart';
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
    var api = await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS);
    var groups = api.getGroups();
    hasTeacherPlan = (groups.contains("ROLE_LEHRER") || groups.contains("ROLE_ADMINISTRATOR"));
  }

  // Get Data
  Future loadRPlan() async{
    if (_loaded == 3) _loaded = 0;
    _days = [];
    _loadDay(APIAction.GET_RPLAN_TODAY);
    _loadDay(APIAction.GET_RPLAN_TOMORROW);
    if (hasTeacherPlan) {
      _loadDay(APIAction.GET_RPLAN_DAYAFTERTOMMOROW);
    } else {
      _loaded++;
    }
  }

  Future _loadDay(APIAction action) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(action);
    if (rplanRequest == null) return;

    var rplanTwo; // ignore: prefer_typing_uninitialized_variables

    var rplanText = await rplanRequest.getRAWRPlan("lehrer", searchedTeacher);
    var rplan = rplanText != null ? jsonDecode(rplanText) : null;
    if (searchedTeacher != null) {
      var rplanTwoText = await rplanRequest.getRAWRPlan("v_lehrer", searchedTeacher);
      rplanTwo = rplanTwoText != null ? jsonDecode(rplanTwoText) : null;
    }
    var newLessons = <Widget>[];

    newLessons.addAll(_preProcessLessonData(rplan));
    newLessons.addAll(_preProcessLessonData(rplanTwo));

    setState(() {
      if (!newLessons.isEmpty) {
        _days.add(DayWidget(
          lessons: newLessons,
          // TODO this should already be saved after rework of api.dart
          dateTime: DateTime.fromMillisecondsSinceEpoch((rplan['entities'].length > 0 ? int.parse(rplan['entities'][0]['vplan']) : int.parse(rplanTwo['entities'][0]['vplan'])) * 1000)
        ));
      }
      _days.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      // Only set to loaded if really loaded
      if (_loaded != 3) _loaded++;
    });
  }


  List<Lesson> _preProcessLessonData(rplan) {
    List<Lesson> newLessons = [];
    if (rplan != null && rplan['entities'].length > 0) {
      var notPrint = [];
      for (int a = 0; a < rplan['entities'].length; a++) {
        for (int b = a + 1; b < rplan['entities'].length; b++) {
          if (rplan['entities'][a]['v_fach'] == rplan['entities'][b]['v_fach'] &&
              rplan['entities'][a]['v_raum'] == rplan['entities'][b]['v_raum'] &&
              rplan['entities'][a]['v_klasse'] ==  rplan['entities'][b]['v_klasse'] &&
              rplan['entities'][a]['klasse'] ==  rplan['entities'][b]['klasse'] &&
              rplan['entities'][a]['art'] == rplan['entities'][b]['art'] &&
              rplan['entities'][a]['fach'] == rplan['entities'][b]['fach'] &&
              rplan['entities'][a]['raum'] == rplan['entities'][b]['raum'] &&
              rplan['entities'][a]['lehrer'] == rplan['entities'][b]['lehrer'] &&
              rplan['entities'][a]['v_lehrer'] == rplan['entities'][b]['v_lehrer']) {
            notPrint.add(b);
            rplan['entities'][a]['stunde'] += "-${rplan['entities'][b]['stunde']}";
          }
        }
      }
      for (int i = 0; i < rplan['entities'].length; i++) {
        if (!notPrint.contains(i)) {
          newLessons.add(Lesson(rplan['entities'][i]));
        }
      }
    }
    return newLessons;
  }
}

// ignore: must_be_immutable
class RPlanDetail extends StatelessWidget {
  RPlanDetail(this.lesson);

  Map<String, dynamic> lesson;
  double width;
  static const TextStyle textStyle  = const TextStyle(fontSize: 25);
  static const TextStyle titleStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    if (lesson['lehrer'] == null) lesson['lehrer'] = "";
    if (lesson['v_lehrer'] == null) lesson['v_lehrer'] = "";
    width = MediaQuery.of(context).size.width;

    List<Widget> widgets = [
      element("Art", lesson['art'], ""),
      element("Stunde", lesson['stunde'], ""),
      element("Fach", lesson['fach'], lesson['v_fach']),
      element("Raum", lesson['raum'], lesson['v_raum']),
      element("Infos", lesson['infos'], ""),
    ];

    if (getTeacherText(lesson['lehrer'], lesson['v_lehrer']).compareTo("") != 0) {
      widgets.insert(1,
          element(getTeacherText(lesson['lehrer'],
              lesson['v_lehrer']),
              lesson['lehrer'],
              lesson['v_lehrer']));
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
    String returnString = lesson['klasse'];

    if (lesson['klasse'] != "" && lesson['fach'] != "") returnString += " - ";
    returnString += lesson['fach'];
    return returnString;
  }

  String getTeacherText(String teacher, String vTeacher) {
    if (teacher.isEmpty && vTeacher.isEmpty) {
      return "";
    }
    return "Lehrer";
  }
}