import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';
import '../components/helpers.dart';
import '../components/timetable.dart';
import '../components/user.dart';
import '../main.dart';

// ignore: must_be_immutable
class User extends StatelessWidget {

  TimeTable timeTable;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: API.of(context).requests.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (timeTable == null) timeTable = TimeTable(snapshot.data.klasse != null ? snapshot.data.stufe + snapshot.data.klasse : null, isTeacher: snapshot.data.isTeacher);
            return UserPage(snapshot.data.appropriateName, timeTable, isTeacher: snapshot.data.isTeacher);
          } else if (!snapshot.hasError) {
            return UserPage(null, WaitingWidget());
          } else {
            return ErrorTextHolder("Die Nutzer Seite ist zur Zeit leider nicht verfügbar");
          }
        });
  }

  static void logout(BuildContext context) {
    API.of(context).setLoginCredentials(null, null);
    KAGAppState.app.setLoggedOut();
    SharedPreferences.getInstance().then((instance) => instance.remove("klasse"));
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Logged out!"),
        action: SnackBarAction(
            label: 'Zurück zum Start!', onPressed: () => KAGAppState.app.goToPage(2))
    ));
  }

}