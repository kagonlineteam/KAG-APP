import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';
import '../api/api_models.dart';
import '../components/timetable.dart';
import '../components/user.dart';
import '../main.dart';

// ignore: must_be_immutable
class User extends StatelessWidget {

  TimeTable timeTable;

  @override
  Widget build(BuildContext context) {
    KAGUser user = API.of(context).requests.getUserInfo();
    if (timeTable == null) timeTable = TimeTable(isTeacher: user.isTeacher);
    return UserPage(user.appropriateName, timeTable, isTeacher: user.isTeacher);
  }

  static void logout(BuildContext context) {
    API.of(context).setLoginCredentials(null, null);
    KAGAppState.app.setLoggedOut();
    SharedPreferences.getInstance().then((instance) {
      instance.remove(SP_CACHE_USER_PRELOAD);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Logged out!"),
        action: SnackBarAction(
            label: 'Zurück zum Start!', onPressed: () => KAGAppState.app.goToPage(0))
    ));
  }

}