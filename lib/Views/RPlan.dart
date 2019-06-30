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

class RPlanState extends State<RPlan> {
  var lessons = <Widget>[];
  APIAction requestDate = APIAction.GET_RPLAN_TODAY;
  static const textStyle = TextStyle(fontSize: 20);
  TextStyle bigText = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle placeholderStyle = TextStyle(fontSize: 15);
  TextStyle smallPlaceholderStyle = TextStyle(fontSize: 10);
  String dateText = "";

  Future _load({force: false}) async {
    var rplanRequest = await KAGApp.api.getAPIRequest(requestDate);
    if (rplanRequest != null) {
      var rplan = jsonDecode(await rplanRequest.getRAWRPlan(null, force: force));
      if (rplan != null) {
        var newLessons = <Widget>[];
        await rplan['vertretungen']
            .forEach((lesson) => newLessons.add(_loadLesson(lesson)));
        setState(() {
          lessons = newLessons;
          dateText = rplan['date'];
        });
      }
    }
  }

  Widget _loadLesson(lesson) {
    return new Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RPlanDetail(lesson))),
        child: Container(
          decoration: BoxDecoration(border: Border(
            top: BorderSide( color: Color.fromRGBO(235, 235, 235, 1))
          )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("", style: smallPlaceholderStyle), //Placeholder
                  Text(lesson['klasse'], style: bigText),
                  Text("", style: placeholderStyle,), //Placeholder
                  Text("", style: textStyle), //Teacher
                  Text("", style: smallPlaceholderStyle), //Placeholder
                ],
              ),
              Column(
                children: <Widget>[
                  Text("", style: smallPlaceholderStyle), //Placeholder
                  Text(lesson['fach'], style: bigText),
                  Text("", style: placeholderStyle,), //Placeholder
                  Text(lesson['art'], style: textStyle), //Nothing (if teacher is shown)
                  Text("", style: smallPlaceholderStyle), //Placeholder
                ],
              ),
              Column(
                children: <Widget>[
                  Text("", style: smallPlaceholderStyle), //Placeholder
                  Text(lesson['stunde'], style: bigText),
                  Text("", style: placeholderStyle,), //Placeholder
                  Text("", style: textStyle), //Art (if teacher is shown)
                  Text("", style: smallPlaceholderStyle), //Placeholder
                ],
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
    _load();
  }

  Future switchToNextDay() async {
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

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
        child: GestureDetector(
            onDoubleTap: switchToNextDay,
            child: RefreshIndicator(
                child: Column(
                  children: <Widget>[
                    Text(dateText, style: TextStyle(fontSize: 30)),
                    Expanded(
                      child: ListView(
                        children: lessons,
                      ),
                    )
                  ],
                ),
                onRefresh: () => _load(force: true))));
  }
}

class RPlanDetail extends StatelessWidget {
  RPlanDetail(this.lesson);

  final lesson;
  static const TextStyle textStyle = const TextStyle(fontSize: 30);

  @override
  Widget build(BuildContext context) {
    if (lesson['lehrer'] == null) lesson['lehrer'] = "";
    if (lesson['v_lehrer'] == null) lesson['v_lehrer'] = "";

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson['klasse'] + " " + lesson['fach']),
        backgroundColor: Color.fromRGBO(47, 109, 29, 1),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(lesson['klasse'], style: textStyle),
                  Text(lesson['stunde'], style: textStyle)
                ],
              ),
              margin: EdgeInsets.fromLTRB(0, 20, 0, 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(lesson['fach'], style: textStyle),
                Text(lesson['v_fach'], style: textStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(lesson['raum'], style: textStyle),
                Text(lesson['v_raum'], style: textStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(lesson['lehrer'], style: textStyle),
                Text(lesson['v_lehrer'], style: textStyle)
              ],
            ),
            Text(lesson['art'], style: textStyle)
          ],
        ),
      ),
    );
  }
}
