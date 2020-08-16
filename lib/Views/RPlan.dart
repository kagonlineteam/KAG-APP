import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../api.dart';
import '../components/helpers.dart';
import '../components/rplan_components.dart';
import '../components/rplan_structure.dart';
import '../main.dart';
/**
class RPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RPlanState();
  }
}

class RPlanState extends State<RPlan> with AutomaticKeepAliveClientMixin<RPlan>, TickerProviderStateMixin {

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      if (!canSeeRPlan) {
        return new Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text("Der Vertretungsplan ist Oberstufenschüler*innen vorbehalten!"),
            ),
          ),
        );
      }
      return Container();
    }, future: _preLoad(),);
  }

  Future _preLoad() async {
    // Load searched Teacher
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(SP_FILTER)) {
      searchedTeacher = preferences.getString(SP_FILTER);
    }

    // Load Settings
    KAGApp.api.getAPIRequest(APIAction.GET_GROUPS).then((api) {
      var groups = api.getGroups();
      canSeeAllDays = (groups.contains("ROLE_LEHRER") || groups.contains("ROLE_ADMINISTRATOR"));

      canSeeRPlan = !groups.contains("ROLE_UNTERSTUFE");

      if (canSeeRPlan) {
        loadRPlan();
      }
    });

  }

  Future loadRPlan({bool force=false}) async{
    _processDay(APIAction.GET_RPLAN_TODAY,    force: force);
    // I know that this should not be down Client Side. But here it is. Limiting students to see the plan of übermorgen on weekends
    if (canSeeAllDays || DateTime.now().weekday < 6) {
      _processDay(APIAction.GET_RPLAN_TOMORROW, force: force);
    }
    if (canSeeAllDays) {
      _processDay(APIAction.GET_RPLAN_DAYAFTERTOMMOROW, force: force);
    }
  }

  Future _processDay(APIAction action, {force=false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(action);
    if (rplanRequest == null) return;

    var rplanTwo; // ignore: prefer_typing_uninitialized_variables

    var rplanText = await rplanRequest.getRAWRPlan("lehrer", searchedTeacher, force: force);
    var rplan = rplanText != null ? jsonDecode(rplanText) : null;
    if (searchedTeacher != null) {
      var rplanTwoText = await rplanRequest.getRAWRPlan("v_lehrer", searchedTeacher, force: force);
      rplanTwo = rplanTwoText != null ? jsonDecode(rplanTwoText) : null;
    }
    var newLessons = <Widget>[];
    int date = 0;

    date = _preProcessLessonData(rplan, newLessons);
    _preProcessLessonData(rplanTwo, newLessons);

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

  static Future _showFilterOptions(BuildContext context) async {
    String searchedTeacher;
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
                //loadRPlan(force: true);
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

  _preProcessLessonData(rplan, newLessons) {
    var date = 0;
    if (rplan != null && rplan['entities'].length > 0) {
      var notPrint = [];
      for (int a = 0; a < rplan['entities'].length; a++) {
        for (int b = a + 1; b < rplan['entities'].length; b++) {
          if (rplan['entities'][a]['v_fach'] ==
              rplan['entities'][b]['v_fach'] &&
              rplan['entities'][a]['v_raum'] ==
                  rplan['entities'][b]['v_raum'] &&
              rplan['entities'][a]['v_klasse'] ==
                  rplan['entities'][b]['v_klasse'] &&
              rplan['entities'][a]['art'] == rplan['entities'][b]['art'] &&
              rplan['entities'][a]['fach'] == rplan['entities'][b]['fach'] &&
              rplan['entities'][a]['raum'] == rplan['entities'][b]['raum'] &&
              rplan['entities'][a]['lehrer'] ==
                  rplan['entities'][b]['lehrer'] &&
              rplan['entities'][a]['v_lehrer'] ==
                  rplan['entities'][b]['v_lehrer']) {
            notPrint.add(b);
            rplan['entities'][a]['stunde'] += "-${rplan['entities'][b]['stunde']}";
          }
        }
      }
      date = int.parse(rplan['entities'].first['vplan']);
      for (int i = 0; i < rplan['entities'].length; i++) {
        if (!notPrint.contains(i)) {
          newLessons.add(Lesson(rplan['entities'][i]));
        }
      }
    }
    return date;
  }

  void _createColumn(List<Widget> lessons, String dateText, APIAction action) {
    DayWidget widget = DayWidget(lessons: lessons, canSeeAllDays: canSeeAllDays, rPlan: this);

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
**/

class RPlanViewWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return RPlan();
  }
}

class RPlan extends State {

  bool hasTeacherPlan = false, canSeeRPlan = false;

  int _loaded = -1; // -1 = Not Preloaded, 0 = Not loaded, 3 = loaded

  String searchedTeacher;

  List<DayWidget> _days;

  static const SP_FILTER  = "RPlan_filter";


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

      //TODO choose the right one automatically
      return RPlanListView(_days);
    } else if (_loaded == 0 && !canSeeRPlan) {
      return ErrorTextHolder("Der Vertretungsplan ist Oberstufenschüler*innen vorbehalten!", barTitle: "VPlan");
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
      if (canSeeRPlan) {
        _loaded = 0;
        loadRPlan();
      }
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

    canSeeRPlan = !groups.contains("ROLE_UNTERSTUFE");
  }

  // Get Data
  Future loadRPlan() async{
    _days = [];
    await _loadDay(APIAction.GET_RPLAN_TODAY);
    await _loadDay(APIAction.GET_RPLAN_TOMORROW);
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
      //TODO ASYNCHRONOUS!
      if (!newLessons.isEmpty) _days.add(DayWidget(lessons: newLessons, date: _getRPlanDate(rplan, rplanTwo)));
      // Only set to loaded if really loaded
      if (_loaded != 3) _loaded++;
    });
  }

  // TODO This method should definitely not be needed anymore after a rework of api.dart
  static String _getRPlanDate(rplan, rplanTwo) {
    int seconds = rplan['entities'].length > 0 ? int.parse(rplan['entities'][0]['vplan']) : int.parse(rplanTwo['entities'][0]['vplan']);
    var datetime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return "${datetime.day}.${datetime.month}";
  }

  List<Lesson> _preProcessLessonData(rplan) {
    List<Lesson> newLessons = [];
    if (rplan != null && rplan['entities'].length > 0) {
      var notPrint = [];
      for (int a = 0; a < rplan['entities'].length; a++) {
        for (int b = a + 1; b < rplan['entities'].length; b++) {
          if (rplan['entities'][a]['v_fach'] ==
              rplan['entities'][b]['v_fach'] &&
              rplan['entities'][a]['v_raum'] ==
                  rplan['entities'][b]['v_raum'] &&
              rplan['entities'][a]['v_klasse'] ==
                  rplan['entities'][b]['v_klasse'] &&
              rplan['entities'][a]['art'] == rplan['entities'][b]['art'] &&
              rplan['entities'][a]['fach'] == rplan['entities'][b]['fach'] &&
              rplan['entities'][a]['raum'] == rplan['entities'][b]['raum'] &&
              rplan['entities'][a]['lehrer'] ==
                  rplan['entities'][b]['lehrer'] &&
              rplan['entities'][a]['v_lehrer'] ==
                  rplan['entities'][b]['v_lehrer']) {
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