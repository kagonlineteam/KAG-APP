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
    KAGApp.app.controller.animateTo(2);
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
            "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$employeeNumber.pdf.png",
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
    return new Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                child: Text(name,
                    style: TextStyle(fontSize: 30)),
                alignment: Alignment.centerLeft,
              ),
              GestureDetector(
                  onTap: logout,
                  child: Container(
                    child: Text("Abmelden",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerRight,
                  )
              )

            ],
          ),
        ),

      ),
      body: Center(
            child: Container(
              child: Container(
                child: timeTable,
                margin: EdgeInsets.all(10),
              ),
              color: Colors.white,
              constraints: BoxConstraints.expand(),
            )
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
