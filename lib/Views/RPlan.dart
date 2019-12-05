import 'dart:async';

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

class RPlanState extends State<RPlan> with AutomaticKeepAliveClientMixin<RPlan>, SingleTickerProviderStateMixin {

  DefaultTabController tabBar;
  TabController controller;

  bool canSeeAllDays = false;
  String searchedTeacher;
  List<String> dateTexts = ["", "", ""];
  int selectedDay = 0;
  static const SP_FILTER = "RPlan_filter";

  Widget todayWidget            = Column();
  Widget tomorrowWidget         = Column();
  Widget dayAfterTomorrowWidget = Column();
  Widget points = Row();

  static const normalText   = TextStyle(fontSize: 20);
  static const bigText      = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const dotActive    = TextStyle(fontSize: 20);
  static const dotInactive  = TextStyle(fontSize: 20, color: Colors.grey);

  Future _loadRPlan({force: false}) async {
    print("Starts loading all days");
    await _loadOneDay(APIAction.GET_RPLAN_TODAY, force: force);
    await _loadOneDay(APIAction.GET_RPLAN_TOMORROW, force: force);
    if (canSeeAllDays) {
      await _loadOneDay(APIAction.GET_RPLAN_DAYAFTERTOMMOROW, force: force);
    }
  }

  Future _loadOneDay(APIAction action, {force: false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(action);
    if (rplanRequest == null) return;

    var rplan = jsonDecode(await rplanRequest.getRAWRPlan(searchedTeacher, force: force));
    if (rplan == null) return;
    var newLessons = <Widget>[];
    await rplan['vertretungen']
        .forEach((lesson) => newLessons.add(_createLesson(lesson)));

    setState(() {
      _createColumn(newLessons, rplan['date'], action);
    });
  }

  void _createColumn(List<Widget> lessons, String dateText, APIAction action) {
    Widget widget = GestureDetector(
      child: RefreshIndicator(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                    children: lessons
                ),
              ),
            ],
          ),
          onRefresh: () => _loadRPlan(force: true)
      ),
    );

    if (action == APIAction.GET_RPLAN_TODAY) {
      todayWidget   = widget;
      dateTexts[0]  = dateText;
    } else if (action == APIAction.GET_RPLAN_TOMORROW) {
      tomorrowWidget  = widget;
      dateTexts[1]    = dateText;
    } else {
      dayAfterTomorrowWidget  = widget;
      dateTexts[2]            = dateText;
    }
  }

  Widget _createLesson(lesson) {
    double width = MediaQuery.of(context).size.width;
    double elementWidth = (width - 60) / 3;
    double elementHeight = 25;

    var bottomLeftText = "";
    var bottomCenterText = lesson['art'];
    var bottomRightText = "";

    if (canSeeAllDays) {
      bottomLeftText = lesson['lehrer'] + " -> " + lesson['v_lehrer'];
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

  void _createTabBar() {
    int length = canSeeAllDays ? 3 : 2;

    controller = new TabController(vsync: this, length: length);
    controller.addListener(_handleTabSelection);

    List<Widget> tabs = [todayWidget,tomorrowWidget];
    if (canSeeAllDays) tabs.add(dayAfterTomorrowWidget);

    tabBar = new DefaultTabController(
      length: length,
      child: Scaffold(
        body: TabBarView(
          controller: controller,
          children: tabs,
        ),
      ),
    );
  }

  Future _showChooseDialog() {

  }

  Future _showFilterOptions() {

  }

  Future _createDots() async {
    if (canSeeAllDays) {
      setState(() {
        points = Container(
          child: Row(
            children: <Widget>[
              Text("•",
                  style: selectedDay == 0
                      ? dotActive
                      : dotInactive),
              Text("•",
                  style: selectedDay == 1
                      ? dotActive
                      : dotInactive),
              Text("•",
                  style: selectedDay == 2
                      ? dotActive
                      : dotInactive)
            ],
          ),
        );
      });
    } else {
      setState(() {
        points = Container(
          child: Row(children: <Widget>[
            Text("•",
                style: selectedDay == 0
                    ? dotActive
                    : dotInactive),
            Text("•",
                style: selectedDay == 1
                    ? dotActive
                    : dotInactive)
          ]),
        );
      });
    }
  }

  _handleTabSelection() {
    selectedDay = controller.index;
    _createDots();
  }


  @override
  void initState() {
    super.initState();
    _preLoad();
    _loadRPlan().then(onValue);
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
            width: MediaQuery.of(context).size.width,
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
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.centerRight,
                    ))
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          tabBar,
          Align(
            child: Container(
              child: Container(
                child: Align(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[points],
                  ),
                  alignment: Alignment.center,
                ),
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(250, 250, 250, 1),
                    borderRadius: BorderRadius.all(Radius.circular(5))),

              ),
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future _preLoad() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // Load searched Teacher
    if (preferences.containsKey(SP_FILTER)) {
      searchedTeacher = preferences.getString(SP_FILTER);
    }
    // Load is Teacher
    canSeeAllDays = ((await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
        .getGroups()
        .contains("ROLE_TEACHER") ||
        (await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS))
            .getGroups()
            .contains("ROLE_ADMINISTRATOR"));
  }


  FutureOr onValue(value) {
    _createTabBar();
    _createDots();
    selectedDay = controller.index;
  }
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

    /*final a = Column(
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
    );*/
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