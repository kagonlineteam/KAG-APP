import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../api.dart';
import '../main.dart';

class RPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RPlanState();
  }
}

class RPlanState extends State<RPlan> with AutomaticKeepAliveClientMixin<RPlan>, TickerProviderStateMixin {

  DefaultTabController tabBar;
  TabController controller;
  String searchedTeacher;

  bool canSeeAllDays      = false;
  List<String> dateTexts  = ["", "", ""];
  int selectedDay         = 0;
  static const SP_FILTER  = "RPlan_filter";

  Widget todayWidget            = Column();
  Widget tomorrowWidget         = Column();
  Widget dayAfterTomorrowWidget = Column();
  Widget points                 = Row();

  static const normalText   = TextStyle(fontSize: 20);
  static const bigText      = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const dotActive    = TextStyle(fontSize: 20);
  static const dotInactive  = TextStyle(fontSize: 20, color: Colors.grey);

  @override
  void initState() {
    super.initState();
    _preLoad();
    _createTabBar();
    _loadRPlan().then(onValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(47, 109, 29, 1),
        actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(
                    dateTexts[selectedDay],
                    style: TextStyle(fontSize: 30),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                ),
                canSeeAllDays ? GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      child: Text("Filtern",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.centerRight,
                    )): Container()
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
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[points],
                    ),
                  ),
                  alignment: Alignment.center,
                ),
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
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

  Future _preLoad() async {
    // Load canSeeAllDays
    var groups = (await KAGApp.api.getAPIRequest(APIAction.GET_GROUPS)).getGroups();
    canSeeAllDays = (groups.contains("ROLE_TEACHER") || groups.contains("ROLE_ADMINISTRATOR"));

    // Load searched Teacher
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(SP_FILTER)) {
      searchedTeacher = preferences.getString(SP_FILTER);
    }
  }

  Future _loadRPlan({force: false}) async {
    await _loadOneDay(APIAction.GET_RPLAN_TODAY,    force: force);
    await _loadOneDay(APIAction.GET_RPLAN_TOMORROW, force: force);
    if (canSeeAllDays) {
      await _loadOneDay(APIAction.GET_RPLAN_DAYAFTERTOMMOROW, force: force);
    }
  }

  Future _loadOneDay(APIAction action, {force: false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(action);
    if (rplanRequest == null) return;

    var rplan = jsonDecode(await rplanRequest.getRAWRPlan("lehrer", searchedTeacher, force: force));
    var rplanTwo = jsonDecode(await rplanRequest.getRAWRPlan("v_lehrer", searchedTeacher, force: force));
    var newLessons = <Widget>[];
    String a = "12345";


    if (rplan != null) {
      await rplan['entities']
          .forEach((lesson) => newLessons.add(_createLesson(lesson)));
      a = rplan['entities'].first['vplan'];
    }
    if (rplanTwo != null) {
      await rplanTwo['entities']
          .forEach((lesson) => newLessons.add(_createLesson(lesson)));
      a = rplanTwo['entities'].first['vplan'];
    }
    if (newLessons.isEmpty) return;

    setState(() {
      int b = int.parse(a);
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(b * 1000);
      var dateText = "${dateTime.day}.${dateTime.month}.";
      _createColumn(newLessons, dateText, action);
    });
  }

  Future _showFilterOptions() async {
    TextEditingController teacher = TextEditingController(text: searchedTeacher);
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
                _loadRPlan(force: true);
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

  _handleTabSelection() {
    selectedDay = controller.index;
    _createDots();
  }

  FutureOr onValue(value) {
    _createTabBar();
    _createDots();
    selectedDay = controller.index;
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
      if (lesson['lehrer'] != null) bottomLeftText = lesson['lehrer'];
      if (lesson['v_lehrer'] != null) bottomLeftText += " -> " + lesson['v_lehrer'];
      bottomCenterText = "";
      bottomRightText = lesson['art'];
    }

    Container c =  new Container(
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
    return c;
  }

  void _createTabBar() {
    int length = canSeeAllDays ? 3 : 2;

    controller = new TabController(vsync: this, length: length);
    controller.addListener(_handleTabSelection);

    List<Widget> tabs = [todayWidget, tomorrowWidget];
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

  Future _createDots() async {
    if (canSeeAllDays) {
      setState(() {
        points = Container(
          color: Colors.white,
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
          color: Colors.white,
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

}

// ignore: must_be_immutable
class RPlanDetail extends StatelessWidget {
  RPlanDetail(this.lesson);

  final lesson;
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