import 'package:flutter/material.dart';
import '../main.dart';
import '../api.dart';
import 'dart:convert';

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

  Widget _loadLesson(lesson) {
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
          child: Container(
            decoration: BoxDecoration(border: Border(
                top: BorderSide( color: Color.fromRGBO(235, 235, 235, 1))
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(0),
                  child:
                  Column(
                    children: <Widget>[
                      Text("                                ", style: smallPlaceholderStyle), //Placeholder
                      Text(lesson['klasse'], style: bigText),
                      Text("", style: placeholderStyle,), //Placeholder
                      Text("", style: textStyle), //Teacher
                      Text("", style: smallPlaceholderStyle), //Placeholder
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.all(0),
                  child:
                  Column(
                    children: <Widget>[
                      Text("                                ", style: smallPlaceholderStyle, overflow: TextOverflow.fade,), //Placeholder
                      Text(lesson['fach'], style: bigText),
                      Text("", style: placeholderStyle,), //Placeholder
                      Text(lesson['art'], style: textStyle), //Nothing (if teacher is shown)
                      Text("", style: smallPlaceholderStyle), //Placeholder
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.all(0),
                  child:
                  Column(
                    children: <Widget>[
                      Text("                                ", style: smallPlaceholderStyle), //Placeholder
                      Text(lesson['stunde'], style: bigText),
                      Text("", style: placeholderStyle,), //Placeholder
                      Text("", style: textStyle), //Art (if teacher is shown)
                      Text("", style: smallPlaceholderStyle), //Placeholder
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _createDots(APIAction.GET_RPLAN_TODAY);
    _load();
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
        child: SimpleDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),

          ),
          children: <Widget>[
            Container(
              child: TextField(
                controller: teacher,
                autocorrect: false,
                enabled: true,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: "Filter"
                ),
              ),
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            ),
            Container(
              child: Text(
                "Der Vertretungsplan wird nach diesem Filter gefiltert",
                style: TextStyle(fontSize: 10),),
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: MaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                      child: Text("Abbrechen"),
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
                Container(
                  child: MaterialButton(
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
                      child: Text("Anwenden"),
                    ),
                  ),
                  alignment: Alignment.bottomRight,
                )
              ],
            )
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
                    child: Text("3.7.17", style: TextStyle(fontSize: 30),),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerLeft,
                  ),
                  onLongPress: _showChooseDialog,
                ),
                GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      child: Text("Filtern",
                          style: TextStyle(fontSize: 20, color: Colors.blue)),
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
