import 'package:flutter/material.dart';

import 'Login.dart' as Login;

import '../main.dart';
import '../api.dart';

class User extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }

}


class UserState extends State<User> {

  Future _load() async {
    if ((await KAGApp.api.getAPIRequest(APIAction.GET_USERNAME)) == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new Login.Login()));
    }
    //TODO Load data needed
  }

  @override
  initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        children: <Widget>[
          MaterialButton(
            child: Text("Logout"),
            onPressed: () => KAGApp.api.setLoginCredentials(null, null),
          )
        ],
      ),
    );
  }

}