import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../main.dart';

class User extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }
}

class UserState extends State<User> with AutomaticKeepAliveClientMixin<User> {
  String name = "";
  Widget timeTable = Row();

  void logout() {
    KAGApp.api.setLoginCredentials(null, null);
    KAGApp.tabs.animateTo(0);
    KAGApp.app.checkLogin();
  }

  Future _load() async {
    KAGApp.api.getAPIRequest(APIAction.GET_USER_INFO).then((request) async {
      String response = await request.getUserInfo();
      var userInfo = jsonDecode(response)['entity'];

      // Set Timetable
      if (userInfo.containsKey("stufe") &&
          (userInfo['stufe'] == "EF" ||
              userInfo['stufe'] == "Q1" ||
              userInfo['stufe'] == "Q2")) {
        _setTimeTable(userInfo['stufe']);
      }

      // Set Name
      if (userInfo.containsKey("stufe")) {
        // Student
        name = userInfo['name'][0];
      } else {
        // Teacher
        name = userInfo['surname'];
      }
    });
  }

  void _setTimeTable(employeeNumber) {
    setState(() {
      timeTable = GestureDetector(
        onTap: () => launch(
            "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$employeeNumber.pdf"),
        child: OrientationBuilder(builder: (context, orientation) {
          return Image.network(
            "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/$employeeNumber.png",
            //height: MediaQuery.of(context).size.height - 100,
          );
        }),
      );
    });
  }

  @override
  initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new SafeArea(
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(children: <Widget>[
                Text(name, style: TextStyle(fontSize: 30)),
                MaterialButton(
                  child: Text("Abmelden"),
                  onPressed: logout,
                )
              ], mainAxisAlignment: MainAxisAlignment.spaceAround),
              timeTable
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ],
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
