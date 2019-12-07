import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import '../main.dart';

class RPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RPlanState();
  }
}

class RPlanState extends State<RPlan>
    with AutomaticKeepAliveClientMixin<RPlan> {
  static const SP_FILTER = "RPlan_filter";

  var lessons = <Widget>[];
  APIAction requestDate = APIAction.GET_RPLAN_TODAY;
  static const textStyle = TextStyle(fontSize: 20);
  static const dotActive = TextStyle(fontSize: 40);
  static const dotInactive = TextStyle(fontSize: 40, color: Colors.grey);
  TextStyle bigText = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle placeholderStyle = TextStyle(fontSize: 15);
  TextStyle smallPlaceholderStyle = TextStyle(fontSize: 10);
  String dateText = "";
  String searchedTeacher;
  bool isTeacher = false;
  bool switchingDays = false;
  Row points = Row();
  static const normalText = TextStyle(fontSize: 20);

  @override
  void initState() {
    super.initState();
    _preLoad();
    _createDots(APIAction.GET_RPLAN_TODAY);
    _load();
  }

  Widget _loadLesson(lesson) {
    double width = MediaQuery.of(context).size.width;
    double elementWidth = (width - 60) / 3;
    double elementHeight = 25;

    var bottomLeftText = "";
    var bottomCenterText = lesson['art'];
    var bottomRightText = "";

    if (isTeacher) {
      if (lesson['lehrer'] != null && lesson['v_lehrer'] != null) {
        bottomLeftText = lesson['lehrer'] + " -> " + lesson['v_lehrer'];
      }
      bottomCenterText = "";
      bottomRightText = lesson['art'];
    }

    return new Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
          onPanUpdate: (details) {
            if (details.delta.dx > 0) {
              switchToLastDay();
            } else if (details.delta.dx < 0) {
              switchToNextDay();
            }
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Color.fromRGBO(235, 235, 235, 1), width: 2))),
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
  }

  Future _preLoad() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // Load searched Teacher
    if (preferences.containsKey(SP_FILTER)) {
      searchedTeacher = preferences.getString(SP_FILTER);
    }
    // Load is Teacher
    var isTeacher = ((await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
            .getGroups()
            .contains("ROLE_TEACHER") ||
        (await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
            .getGroups()
            .contains("ROLE_ADMINISTRATOR"));
    setState(() {
      this.isTeacher = isTeacher;
    });
  }

  Future _load({force: false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(requestDate);
    if (rplanRequest != null) {
      var rplan = jsonDecode(await rplanRequest.getRAWRPlan("lehrer", searchedTeacher, force: force));
      var rplanTwo = jsonDecode(await rplanRequest.getRAWRPlan("v_lehrer", searchedTeacher, force: force));
      var newLessons = <Widget>[];
      String a;
      if (rplan != null) {
        await rplan['entities']
            .forEach((lesson) => newLessons.add(_loadLesson(lesson)));
        a = rplan['entities'][0]['vplan'];
      }
      if (rplanTwo != null) {
        await rplanTwo['entities']
            .forEach((lesson) => newLessons.add(_loadLesson(lesson)));
        a = rplanTwo['entities'][0]['vplan'];
        print(newLessons);
      }
      if (newLessons.isEmpty) return;

      setState(() {
        lessons = newLessons;
        int b = int.parse(a);
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(b * 1000);
        dateText = "${dateTime.day}.${dateTime.month}.";
      });
      _createDots(requestDate);
    }
    switchingDays = false;
  }

  Future switchToNextDay() async {
    if (!switchingDays) {
      switchingDays = true;
      if (requestDate == APIAction.GET_RPLAN_TODAY) {
        requestDate = APIAction.GET_RPLAN_TOMORROW;
      } else if (requestDate == APIAction.GET_RPLAN_TOMORROW && isTeacher) {
        requestDate = APIAction.GET_RPLAN_DAYAFTERTOMMOROW;
      } else {
        requestDate = APIAction.GET_RPLAN_TODAY;
      }
      _load();
    }
  }

  Future switchToLastDay() async {
    if (!switchingDays) {
      switchingDays = true;
      if (isTeacher) {
        requestDate = APIAction.GET_RPLAN_DAYAFTERTOMMOROW;
      } else if (requestDate == APIAction.GET_RPLAN_TODAY) {
        requestDate = APIAction.GET_RPLAN_TOMORROW;
      } else if (requestDate == APIAction.GET_RPLAN_TOMORROW) {
        requestDate = APIAction.GET_RPLAN_TODAY;
      } else {
        requestDate = APIAction.GET_RPLAN_TOMORROW;
      }
      _load();
    }
  }

  Future _createDots(APIAction request) async {
    if (isTeacher) {
      setState(() {
        points = Row(
          children: <Widget>[
            Text(".",
                style: request == APIAction.GET_RPLAN_TODAY
                    ? dotActive
                    : dotInactive),
            Text(".",
                style: request == APIAction.GET_RPLAN_TOMORROW
                    ? dotActive
                    : dotInactive),
            Text(".",
                style: request == APIAction.GET_RPLAN_DAYAFTERTOMMOROW
                    ? dotActive
                    : dotInactive)
          ],
        );
      });
    } else {
      setState(() {
        points = Row(children: <Widget>[
          Text(".",
              style: request == APIAction.GET_RPLAN_TODAY
                  ? dotActive
                  : dotInactive),
          Text(".",
              style: request == APIAction.GET_RPLAN_TOMORROW
                  ? dotActive
                  : dotInactive)
        ]);
      });
    }
  }

  Future _showFilterOptions() async {
    TextEditingController teacher =
        TextEditingController(text: searchedTeacher);
    showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: CupertinoAlertDialog(
          content: Column(
            children: <Widget>[
              Container(
                child: CupertinoTextField(
                  placeholder: "Filter",
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
                  "Der Vertretungsplan wird nach diesem Filter gefiltert",
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
                  searchedTeacher = null;
                  preferences.remove(SP_FILTER);
                } else {
                  searchedTeacher = teacher.text;
                  preferences.setString(SP_FILTER, searchedTeacher);
                }
                _load();
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

  Future _showChooseDialog() async {
    /*TODO:
      * Make text dynamic (as in the iOS App
      * Spacing to horizontal border
     */

    showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: CupertinoAlertDialog(
          actions: <Widget>[
            Container(
              height: 20,
            ),
            Material(
              color: Color.fromRGBO(0, 0, 255, 1),
              borderRadius: BorderRadius.circular(30.0),
              child: MaterialButton(
                  onPressed: () {
                    requestDate = APIAction.GET_RPLAN_TODAY;
                    _load();
                    Navigator.pop(context);
                  },
                  child: Text("Heute",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal))),
            ),
            Container(
              height: 20,
            ),
            Material(
              color: Color.fromRGBO(0, 0, 255, 1),
              borderRadius: BorderRadius.circular(30.0),
              child: MaterialButton(
                  onPressed: () {
                    requestDate = APIAction.GET_RPLAN_TOMORROW;
                    _load();
                    Navigator.pop(context);
                  },
                  child: Text("Morgen",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal))),
            ),
            isTeacher
                ? Container(
                    height: 20,
                  )
                : Row(),
            isTeacher
                ? Material(
                    color: Color.fromRGBO(0, 0, 255, 1),
                    borderRadius: BorderRadius.circular(30.0),
                    child: MaterialButton(
                        onPressed: () {
                          requestDate = APIAction.GET_RPLAN_DAYAFTERTOMMOROW;
                          _load();
                          Navigator.pop(context);
                        },
                        child: Text("Übermorgen",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal))),
                  )
                : Row(),
            Container(
              height: 20,
            )
          ],
        ));
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(47, 109, 29, 1),
        actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    child: Text(
                      dateText,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerLeft,
                  ),
                  onLongPress: _showChooseDialog,
                  onTap: switchToNextDay,
                ),
                isTeacher
                    ? GestureDetector(
                        onTap: _showFilterOptions,
                        child: Container(
                          child:
                              Text("Filtern", style: TextStyle(fontSize: 20)),
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.centerRight,
                        ))
                    : Container()
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
          child: GestureDetector(
              child: RefreshIndicator(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView(
                          children: lessons,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[points],
                      )
                    ],
                  ),
                  onRefresh: () => _load(force: true)))),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// ignore: must_be_immutable
class RPlanDetail extends StatelessWidget {
  RPlanDetail(this.lesson);

  final lesson;
  static const TextStyle textStyle = const TextStyle(fontSize: 25);
  static const TextStyle titleStyle =
      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  double width;

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

    if (getTeacherText(lesson['lehrer'], lesson['v_lehrer']).compareTo("") !=
        0) {
      widgets.insert(
          1,
          element(getTeacherText(lesson['lehrer'], lesson['v_lehrer']),
              lesson['lehrer'], lesson['v_lehrer']));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson['klasse'] + " - " + lesson['fach']),
      ),
      body: SafeArea(child: Column(children: widgets)),
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
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  title,
                  style: titleStyle,
                ),
                width: width - 40,
                height: 30,
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                child: Text(
                  first,
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
                width: (width - 70) / 2,
                height: 30,
              ),
              Container(
                child: Text(
                  arrow,
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                width: 30,
                height: 30,
              ),
              Container(
                child: Text(
                  second,
                  style: textStyle,
                  textAlign: TextAlign.right,
                ),
                width: (width - 70) / 2,
                height: 30,
              )
            ],
          )
        ],
      ),
    );
    return container;
  }

  String getTeacherText(String teacher, String vTeacher) {
    if (teacher.isEmpty && vTeacher.isEmpty) {
      return "";
    }
    return "Lehrer";
  }
}
