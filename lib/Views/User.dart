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

class UserState extends State<User> {
  var username = "";
  var timeTableButton = Row();

  void logout() {
    KAGApp.api.setLoginCredentials(null, null);
    KAGApp.tabs.animateTo(0);
    KAGApp.app.checkLogin();
  }

  Future _load() async {
    KAGApp.api.getAPIRequest(APIAction.GET_USERNAME).then((apiRequest) =>
        apiRequest != null
            ? setState(() => username = apiRequest.getUsername())
            : null);
    KAGApp.api.getAPIRequest(APIAction.GET_GROUPS).then((apiRequest) => _loadTimeTableURL(apiRequest));
  }

  Future _loadTimeTableURL(groupsAPIRequest) async {
    if (groupsAPIRequest != null) {
      if (groupsAPIRequest.getGroups().contains("ROLE_OBERSTUFE") || groupsAPIRequest.getGroups().contains("ROLE_ADMINISTRATOR")) {
        final employeeNumber = await (await KAGApp.api.getAPIRequest(APIAction.GET_USER_INFO)).getUserInfo("employeeNumber");
        setState(() {
          timeTableButton = Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.green,
                      child: MaterialButton(
                        onPressed: () => launch("https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$employeeNumber.pdf"),
                        child: Text("Stundenraster"),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  )
              )
            ],
          );
        });
      }
    }
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
            Text(username, style: TextStyle(fontSize: 30)),
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
}
