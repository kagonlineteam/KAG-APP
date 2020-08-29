import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kag/components/timetable.dart';
import 'package:kag/components/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../main.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: KAGApp.api.requests.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return UserPage(snapshot.data.appropriateName, snapshot.data.stufe != null ? TimeTable(snapshot.data.klasse != null ? snapshot.data.stufe + snapshot.data.klasse : snapshot.data.stufe) : null);
          } else {
            return UserPage(null, null);
          }
        });
  }

  static void logout(BuildContext context) {
    KAGApp.api.setLoginCredentials(null, null);
    KAGApp.app.setLoggedOut();
    SharedPreferences.getInstance().then((instance) => instance.remove("klasse"));
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Logged out!"),
        action: SnackBarAction(
            label: 'Zurück zum Start!', onPressed: () => KAGApp.app.goToPage(2))
    ));
  }

}