import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart';
import '../main.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class RPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RPlanState();
  }
}

class RPlanState extends State<RPlan>
    with AutomaticKeepAliveClientMixin<RPlan>, SingleTickerProviderStateMixin {

  DefaultTabController tabBar;
  TabController controller;

  bool canSeeAllDays = false;
  String searchedTeacher;
  List<String> dateTexts = ["", "", ""];
  int selectedDay;

  var lessonsToday = <Widget>[];
  var lessonsTomorrow = <Widget>[];
  var lessonsDayAfterTomorrow = <Widget>[];

  Column todayWidget;
  Column tomorrowWidget;
  Column dayAfterTomorrowWidget;

  static const normalText = TextStyle(fontSize: 20);
  static const bigText = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  Future _loadDay(APIAction action, {force: false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(action);
    if (rplanRequest != null) {
      var rPlan = jsonDecode(
          await rplanRequest.getRAWRPlan(searchedTeacher, force: force)
      );
      if (rPlan != null) {
        var newLessons = <Widget>[];
        await rPlan['vertretungen']
            .forEach((lesson) => newLessons.add(_createLesson(lesson)));
        setState(() {
          if (action == APIAction.GET_RPLAN_TODAY) {
            lessonsToday = newLessons;
            dateTexts[0] = rPlan['date'];
          } else if (action == APIAction.GET_RPLAN_TOMORROW) {
            lessonsTomorrow = newLessons;
            dateTexts[1] = rPlan['date'];
          } else if (action == APIAction.GET_RPLAN_DAYAFTERTOMMOROW) {
            lessonsDayAfterTomorrow = newLessons;
            dateTexts[2] = rPlan['date'];
          }
        });
      }
    }
  }

  void _loadAllDays({force: false}) {
    _loadDay(APIAction.GET_RPLAN_TODAY, force: force);
    _loadDay(APIAction.GET_RPLAN_TOMORROW, force: force);
    if (canSeeAllDays) {
      _loadDay(APIAction.GET_RPLAN_DAYAFTERTOMMOROW, force: force);
    }

  }

  void _createColumnFromList() {
    todayWidget = Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: lessonsToday,
          ),
        )
      ],
    );
    tomorrowWidget = Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: lessonsTomorrow,
          ),
        )
      ],
    );
    dayAfterTomorrowWidget = Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: lessonsDayAfterTomorrow,
          ),
        )
      ],
    );
  }

  Widget _createLesson(lesson) {
    double width = MediaQuery.of(context).size.width;
    double elementWidth = (width - 60) / 3;
    double elementHeight = 25;

    var bottomLeftText = "";
    var bottomCenterText = lesson['art'];
    var bottomRightText = "";

    if (canSeeAllDays) {
      bottomLeftText = lesson['lehrer'] + "->" + lesson['v_lehrer'];
      bottomCenterText = "";
      bottomRightText = lesson['art'];
    }

    return new Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color.fromRGBO(235, 235, 235, 1)))),
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
                            style: normalText,
                            textAlign: TextAlign.left),
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
                            style: normalText,
                            textAlign: TextAlign
                                .center),
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
                            style: normalText,
                            textAlign:
                            TextAlign.right),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  void _createTabBar() {
    List<Widget> children;
    if (canSeeAllDays) {
      children = [todayWidget, tomorrowWidget, dayAfterTomorrowWidget];
    } else {
      children = [todayWidget, tomorrowWidget];
    }

    var tabs = <Widget>[Tab(text: ".",), Tab(text: ".",)];
    if (canSeeAllDays) {
      tabs.add(Tab(text: ".",));
    }

    int length = canSeeAllDays ? 3 : 2;

    controller = new TabController(vsync: this, length: length);
    tabBar = new DefaultTabController(
      length: length,
      child: Scaffold(
        body: TabBarView(
          controller: controller,
          children: children,
        ),
        bottomNavigationBar: Container(
          child: TabBar(
            //controller: tabController,
            tabs: tabs,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 30),
            indicatorColor: Colors.transparent,
            labelColor: Colors.black,
            labelPadding: EdgeInsets.only(right: 10.0, left: 10.0),

          ),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Future _showChooseDialog() {

  }

  Future _showFilterOptions() {

  }


  @override
  void initState() {
    super.initState();
    _loadAllDays();
    _createColumnFromList();
    _createTabBar();
    selectedDay = controller.index;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                    child: Text(
                      dateTexts[selectedDay],
                      style: TextStyle(fontSize: 30),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerLeft,
                  ),
                  onLongPress: _showChooseDialog,
                ),
                GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      child: Text("Filtern",
                          style: TextStyle(
                              fontSize: 20, color: CupertinoColors.activeBlue)),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.centerRight,
                    ))
              ],
            ),
          )
        ],
      ),
      body: tabBar,
    );
  }

  @override
  bool get wantKeepAlive => true;


/*
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
   */
}

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

    final a = Column(
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
              child: Text(getTeacherText(lesson['lehrer'], lesson['v_lehrer']),
                  style: titleStyle),
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
    );
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

  String getTeacherText(String teacher, String v_teacher) {
    if (teacher.isEmpty && v_teacher.isEmpty) {
      return "";
    }
    return "Lehrer";
  }
}