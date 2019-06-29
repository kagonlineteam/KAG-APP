import 'package:flutter/material.dart';

import '../main.dart';

class User extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }

}


class UserState extends State<User> {

  void logout() {
    KAGApp.api.setLoginCredentials(null, null);
    KAGApp.tabs.animateTo(0);
    KAGApp.app.checkLogin();
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      child: Column(
        children: <Widget>[
          MaterialButton(
            child: Text("Logout"),
            onPressed: logout,
          )
        ],
      ),
    );
  }

}