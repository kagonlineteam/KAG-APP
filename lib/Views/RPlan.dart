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

  DefaultTabController tabBar = DefaultTabController(length: 0, child: Text(""),);
  TabController controller;
  String searchedTeacher;

  bool canSeeAllDays      = false;
  bool canSeeRPlan        = true;
  List<String> dateTexts  = ["", "", ""];
  List<String> renderedDateTexts  = ["", "", ""];
  int selectedDay         = 0;
  static const SP_FILTER  = "RPlan_filter";

  Widget todayWidget            = Center(child: Text("Der Vertretungsplan wird noch geladen..."));
  Widget tomorrowWidget         = Center(child: Text("Der Vertretungsplan wird noch geladen..."));
  Widget dayAfterTomorrowWidget = Center(child: Text("Der Vertretungsplan wird noch geladen..."));
  Widget points                 = Row();

  static const normalText   = TextStyle(fontSize: 20);
  static const bigText      = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const dotActive    = TextStyle(fontSize: 20);
  static const dotInactive  = TextStyle(fontSize: 20, color: Colors.grey);

  @override
  void initState() {
    super.initState();
    _preLoad();
    if (canSeeRPlan) {
      _loadRPlan();
    }
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
    if (!canSeeRPlan) {
      return new Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text("Der Vertretungsplan ist Oberstufenschüler*innen vorbehalten!"),
        ),
      );
    }

    return new Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                child: Text(renderedDateTexts[selectedDay],
                    style: TextStyle(fontSize: 30)),
                alignment: Alignment.centerLeft,
              ),
              canSeeAllDays ? GestureDetector(
                  onTap: _showFilterOptions,
                  child: Container(
                    child: Text("Filtern",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerRight,
                  )
              ): Container(),

            ],
          ),
        ),

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
    var groups = KAGApp.api.getAPIRequestSync(APIAction.GET_GROUPS).getGroups();
    // Load canSeeAllDays
    canSeeAllDays = (groups.contains("ROLE_LEHRER") || groups.contains("ROLE_ADMINISTRATOR"));

    canSeeRPlan = !groups.contains("ROLE_UNTERSTUFE");

    // Load searched Teacher
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(SP_FILTER)) {
      searchedTeacher = preferences.getString(SP_FILTER);
    }
  }

  Future _loadRPlan({force: false}) async{
    _processDay(APIAction.GET_RPLAN_TODAY,    force: force);
    // I know that this should not be down Client Side. But here it is. Limiting students to see the plan of übermorgen on weekends
    if (canSeeAllDays || DateTime.now().weekday < 6) {
      _processDay(APIAction.GET_RPLAN_TOMORROW, force: force);
    }
    if (canSeeAllDays) {
      _processDay(APIAction.GET_RPLAN_DAYAFTERTOMMOROW, force: force);
    }
  }

  Future _processDay(APIAction action, {force: false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(action);
    if (rplanRequest == null) return;

    var rplanTwo;

    var rplanText = await rplanRequest.getRAWRPlan("lehrer", searchedTeacher, force: force);
    var rplan = rplanText != null ? jsonDecode(rplanText) : null;
    if (searchedTeacher != null) {
      var rplanTwoText = await rplanRequest.getRAWRPlan("v_lehrer", searchedTeacher, force: force);
      rplanTwo = rplanTwoText != null ? jsonDecode(rplanTwoText) : null;
    }
    var newLessons = <Widget>[];
    int date = 0;


    if (rplan != null && rplan['entities'].length > 0) {
      await rplan['entities']
          .forEach((lesson) => newLessons.add(_createLesson(lesson)));
      date = int.parse(rplan['entities'].first['vplan']);
    }
    if (rplanTwo != null && rplanTwo['entities'].length > 0) {
      await rplanTwo['entities']
          .forEach((lesson) => newLessons.add(_createLesson(lesson)));
      date = int.parse(rplanTwo['entities'].first['vplan']);
    }
    if (newLessons.isEmpty) {
      // Reset to default!
      if (action == APIAction.GET_RPLAN_TODAY) {
        todayWidget   = Center(child: Text("Der Vertretungsplan wird noch geladen..."));
        dateTexts[0] = "";
      } else if (action == APIAction.GET_RPLAN_TOMORROW) {
        tomorrowWidget  = Center(child: Text("Der Vertretungsplan wird noch geladen..."));
        dateTexts[1] = "";
      } else {
        dayAfterTomorrowWidget  = Center(child: Text("Der Vertretungsplan wird noch geladen..."));
        dateTexts[2] = "";
      }
      setState(() {
        _createTabBar();
        _handleTabSelection();
      });
      return;
    }

    setState(() {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      var dateText = "${dateTime.day}.${dateTime.month}.";
      _createColumn(newLessons, dateText, action);
      _createTabBar();
      _handleTabSelection();
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
    int length = 0;
    List<Widget> tabs = [];
    List <String> renderedDateTexts = [];

    if (!(todayWidget is Center)) {
      length++;
      tabs.add(todayWidget);
      renderedDateTexts.add(dateTexts[0]);
    }
    if (!(tomorrowWidget is Center)) {
      length++;
      tabs.add(tomorrowWidget);
      renderedDateTexts.add(dateTexts[1]);
    }
    if (!(dayAfterTomorrowWidget is Center)) {
      length++;
      tabs.add(dayAfterTomorrowWidget);
      renderedDateTexts.add(dateTexts[2]);
    }

    if (tabs.isEmpty) {
      if (canSeeAllDays) {
        tabs.add(Center(child: Container(child: Text("Es gibt keine Vertretungen für Sie. Sollte dies unerwartet sein und Sie einen Filter konfiguriert haben, so überprüfen sie bitte das eingebene Kürzel."), margin: EdgeInsets.all(10),)));
      } else {
        tabs.add(Center(child: Text("Es gibt keine Vertretung für dich.")));
      }
      length++;
    }


    // Populate with empty Strings to not cause errors
    while (renderedDateTexts.length < 3) {
      renderedDateTexts.add("");
    }
    // After there should be no reason for a null pointer place the texts to be rendered
    this.renderedDateTexts = renderedDateTexts;

    controller = new TabController(vsync: this, length: length);
    controller.addListener(_handleTabSelection);

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
    List<Widget> elements = [];

    for (int i = 0; i < controller.length; i++) {
      elements.add(Text("•",
          style: selectedDay == i
              ? dotActive
              : dotInactive)
      );
    }

    setState(() {
      points = Container(
        color: Colors.white,
        child: Row(
          children: elements
        ),
      );
    });
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