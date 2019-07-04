import 'package:flutter/material.dart';
import '../main.dart';
import '../api.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class RPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RPlanState();
  }
}

class RPlanState extends State<RPlan> with AutomaticKeepAliveClientMixin<RPlan>{
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
  bool switchingDays = false;
  Row points = Row();

  @override
  void initState() {
    super.initState();
    _createDots(APIAction.GET_RPLAN_TODAY);
    _load();
  }

  Widget _loadLesson(lesson) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double elementWidth = (width - 60) / 3;
    double elementHeight = 25;

    return new Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dx > 0) {
              switchToLastDay();
            } else if (details.delta.dx < 0) {
              switchToNextDay();
            }
          },
          onTap: () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
          child: Container(
            decoration: BoxDecoration(border: Border(
                top: BorderSide(color: Color.fromRGBO(235, 235, 235, 1))
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: elementWidth,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: elementWidth,
                        height: elementHeight,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(lesson['klasse'], style: bigText,
                            textAlign: TextAlign.left),
                      ),
                      Container(
                        width: elementWidth,
                        height: elementHeight,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text("", style: textStyle,
                            textAlign: TextAlign.left), //Teacher
                      ),
                    ],
                  ),
                ),
                Container(
                  width: elementWidth,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: elementWidth,
                        height: elementHeight,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(lesson['fach'], style: bigText,
                            textAlign: TextAlign.center),
                      ),
                      Container(
                        width: elementWidth,
                        height: elementHeight,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(lesson['art'], style: textStyle,
                            textAlign: TextAlign
                                .center), //Nothing (if teacher is shown)
                      ),
                    ],
                  ),
                ),
                Container(
                  width: elementWidth,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: elementWidth,
                        height: elementHeight,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(lesson['stunde'], style: bigText,
                            textAlign: TextAlign.right),
                      ),
                      Container(
                        width: elementWidth,
                        height: elementHeight,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text("", style: textStyle,
                            textAlign: TextAlign
                                .right), //Art (if teacher is shown)
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }

  Future _load({force: false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(requestDate);
    if (rplanRequest != null) {
      var rplan = jsonDecode(await rplanRequest.getRAWRPlan(searchedTeacher, force: force));
      if (rplan != null) {
        var newLessons = <Widget>[];
        await rplan['vertretungen']
            .forEach((lesson) => newLessons.add(_loadLesson(lesson)));
        setState(() {
          lessons = newLessons;
          dateText = rplan['date'];
        });
        _createDots(requestDate);
      }
    }
    switchingDays = false;
  }

  Future switchToNextDay() async {
    if (!switchingDays) {
      switchingDays = true;
      if (requestDate == APIAction.GET_RPLAN_TODAY) {
        requestDate = APIAction.GET_RPLAN_TOMORROW;
      } else if (requestDate == APIAction.GET_RPLAN_TOMORROW &&
          ((await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
              .getGroups()
              .contains("ROLE_TEACHER") ||
              (await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
                  .getGroups()
                  .contains("ROLE_ADMINISTRATOR"))) {
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
      if (requestDate == APIAction.GET_RPLAN_TODAY &&
          ((await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
              .getGroups()
              .contains("ROLE_TEACHER") ||
              (await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
                  .getGroups()
                  .contains("ROLE_ADMINISTRATOR"))) {
        requestDate = APIAction.GET_RPLAN_DAYAFTERTOMMOROW;
      } else if (requestDate == APIAction.GET_RPLAN_TODAY) {
        requestDate = APIAction.GET_RPLAN_TOMORROW;
      } else if (requestDate == APIAction.GET_RPLAN_TOMORROW ){
        requestDate = APIAction.GET_RPLAN_TODAY;
      } else {
        requestDate = APIAction.GET_RPLAN_TOMORROW;
      }
      _load();
    }
  }

  Future _createDots(APIAction request) async {
    if ((await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
        .getGroups()
        .contains("ROLE_TEACHER") ||
        (await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
            .getGroups()
            .contains("ROLE_ADMINISTRATOR")) {
      setState(() {
        points = Row(
          children: <Widget>[
            Text(".", style: request == APIAction.GET_RPLAN_TODAY ? dotActive : dotInactive),
            Text(".", style: request == APIAction.GET_RPLAN_TOMORROW ? dotActive : dotInactive),
            Text(".", style: request == APIAction.GET_RPLAN_DAYAFTERTOMMOROW ? dotActive : dotInactive)
          ],
        );
      });
    } else {
      setState(() {
        points = Row(
            children: <Widget>[
              Text(".", style: request == APIAction.GET_RPLAN_TODAY ? dotActive : dotInactive),
              Text(".", style: request == APIAction.GET_RPLAN_TOMORROW ? dotActive : dotInactive)
            ]
        );
      });
    }
  }

  Future _showFilterOptions() async {
    TextEditingController teacher = TextEditingController(
        text: searchedTeacher);
    showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: CupertinoAlertDialog(
            content: Column(
              children: <Widget>[
                Container(
                  child: CupertinoTextField(
                    placeholder: "Filter",
                    placeholderStyle: TextStyle(color: Color.fromRGBO(150, 150, 150, 1)),
                    controller: teacher,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color.fromRGBO(47, 109, 29, 1))
                      )
                    ),

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
                  child: Text("Abbrechen", style: TextStyle(color: CupertinoColors.activeBlue)),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  if (teacher.text == "") {
                    searchedTeacher = null;
                  } else {
                    searchedTeacher = teacher.text;
                  }
                  _load();
                  Navigator.pop(context);
                },
                child: Container(
                  child: Text("Anwenden", style: TextStyle(color: CupertinoColors.activeBlue),),
                ),
              ),
            ],
        )

    );
  }

  Future _showChooseDialog() async {
    final isTeacher = ((await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
        .getGroups()
        .contains("ROLE_TEACHER") ||
        (await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
            .getGroups()
            .contains("ROLE_ADMINISTRATOR"));
    showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: new Dialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Material(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(onPressed: () {
                  requestDate = APIAction.GET_RPLAN_TODAY;
                  _load();
                  Navigator.pop(context);
                }, child: Text("Heute")),
              ),
              Material(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(onPressed: () {
                  requestDate = APIAction.GET_RPLAN_TOMORROW;
                  _load();
                  Navigator.pop(context);
                }, child: Text("Morgen")),
              ),
              isTeacher ? Material(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(onPressed: () {
                  requestDate = APIAction.GET_RPLAN_DAYAFTERTOMMOROW;
                  _load();
                  Navigator.pop(context);
                }, child: Text("Übermorgen")),
              ) : Row()
            ],
          ),
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
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    child: Text(dateText, style: TextStyle(fontSize: 30),),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerLeft,
                  ),
                  onLongPress: _showChooseDialog,
                ),
                GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      child: Text("Filtern",
                          style: TextStyle(fontSize: 20, color: CupertinoColors.activeBlue)),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.centerRight,
                    )
                )
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
                        children: <Widget>[
                          points
                        ],
                      )
                    ],
                  ),
                  onRefresh: () => _load(force: true)))),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RPlanDetail extends StatelessWidget {
  RPlanDetail(this.lesson);

  final lesson;
  static const TextStyle textStyle = const TextStyle(fontSize: 30);
  static const TextStyle titleStyle = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    if (lesson['lehrer'] == null) lesson['lehrer'] = "";
    if (lesson['v_lehrer'] == null) lesson['v_lehrer'] = "";

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson['klasse'] + " - " + lesson['fach']),
        backgroundColor: Color.fromRGBO(47, 109, 29, 1),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[

            Text(lesson['art'], style: textStyle),

            Column(
              children: <Widget>[
                Container(
                  child: Text("Allgemein", style: titleStyle),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(lesson['klasse'], style: textStyle),
                    Text(lesson['stunde'], style: textStyle)
                  ],
                ),
              ],
            ),

            Column(
              children: <Widget>[
                Container(
                  child: Text("Fach", style: titleStyle),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(lesson['fach'], style: textStyle),
                    Text(lesson['v_fach'], style: textStyle)
                  ],
                ),
              ],
            ),

            Column(
              children: <Widget>[
                Container(
                  child: Text("Raum", style: titleStyle),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(lesson['raum'], style: textStyle),
                    Text(lesson['v_raum'], style: textStyle)
                  ],
                ),
              ],
            ),

            Column(
              children: <Widget>[
                Container(
                  child: Text(getTeacherText(lesson['lehrer'], lesson['v_lehrer']), style: titleStyle),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(lesson['lehrer'], style: textStyle),
                    Text(lesson['v_lehrer'], style: textStyle)
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  String getTeacherText(String teacher, String v_teacher) {
    if (teacher.isEmpty && v_teacher.isEmpty) {
      return "";
    }
    return "Lehrer";
  }
}
