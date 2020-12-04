import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';
import '../components/helpers.dart';
import '../components/timetable.dart';
import '../components/user.dart';
import '../main.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: API.of(context).requests.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return UserPage(snapshot.data.appropriateName, snapshot.data.stufe != null ? TimeTable(snapshot.data.klasse != null ? snapshot.data.stufe + snapshot.data.klasse : snapshot.data.stufe) : null);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Logged out!"),
        action: SnackBarAction(
            label: 'Zurück zum Start!', onPressed: () => KAGAppState.app.goToPage(2))
    ));
  }

}