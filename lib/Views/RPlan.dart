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
  static const textStyle = TextStyle(fontSize: 20);

  Future _load() async {
    var rplan = jsonDecode(
        await (await KAGApp.api.getAPIRequest(APIAction.GET_RPLAN_TODAY))
            .getRAWRPlan(null));
    var newLessons = <Widget>[];
    await rplan['vertretungen'].forEach((lesson) => newLessons.add(_loadLesson(lesson)));
    setState(() {
      lessons = newLessons;
    });
  }

  Widget _loadLesson(lesson) {
    return new Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(lesson['klasse'], style: textStyle),
              ),
              Container(
                child: Text(lesson['fach'], style: textStyle),
              ),
              Container(
                child: Text(lesson['stunde'], style: textStyle),
              ),
            ],
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Text(lesson['art'], style: textStyle),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: ListView(
      children: lessons,
    ));
  }
}
