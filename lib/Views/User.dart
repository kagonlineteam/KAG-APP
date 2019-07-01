import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../api.dart';

class User extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }
}

class UserState extends State<User> with AutomaticKeepAliveClientMixin<User>{
  var name = "";
  var timeTableButton = Row();

  void logout() {
    KAGApp.api.setLoginCredentials(null, null);
    KAGApp.tabs.animateTo(0);
    KAGApp.app.checkLogin();
  }

  Future _load() async {
    KAGApp.api.getAPIRequest(APIAction.GET_USER_INFO).then((request) async {
      Map<String, String> userInfo = await request.getUserInfo(["sn", "givenName", "employeeNumber"]);

      // Set Timetable
      if (userInfo.containsKey("employeeNumber") && (userInfo['employeeNumber'] == "EF" || userInfo['employeeNumber'] == "Q1" || userInfo['employeeNumber'] == "Q2")){
        _setTimeTable(userInfo['employeeNumber']);
      }

      // Set Name
      if (userInfo.containsKey("employeeNumber")) {
        // Student
        name = userInfo['givenName'];
      } else {
        // Teacher
        name = userInfo['sn'];
      }
    });
  }

  void _setTimeTable(employeeNumber) {
    setState(() {
      timeTableButton = Row(
        children: <Widget>[
          Expanded(
              child: Container(
                child: Material(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Color.fromRGBO(47, 109, 29, 1),
                  child: MaterialButton(
                    onPressed: () => launch("https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$employeeNumber.pdf"),
                    child: Text("Stundenraster", style: TextStyle(color: Colors.white),),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              )
          )
        ],
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
    return new SafeArea(
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Text(name, style: TextStyle(fontSize: 30)),
            MaterialButton(
              child: Text("Logout"),
              onPressed: logout,
            )
          ], mainAxisAlignment: MainAxisAlignment.spaceAround),
          timeTableButton
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
