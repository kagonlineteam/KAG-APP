import 'package:flutter/cupertino.dart';

import './Calendar.dart'	as Calendar; // ignore: library_prefixes
import './Home.dart'      as Home; // ignore: library_prefixes
import './Login.dart'     as Login; // ignore: library_prefixes
import './News.dart'      as News; // ignore: library_prefixes
import './RPlan.dart'     as RPlan; // ignore: library_prefixes
import './User.dart'      as User; // ignore: library_prefixes

/// Used by main.dart
///

// ignore: non_constant_identifier_names
List<Widget> AppViews({bool loggedIn = true}) {
  return <Widget>[
    new Calendar.Calendar(),
    new RPlan.RPlanViewWidget(),
    new Home.Home(),
    loggedIn ? new User.User() : new Login.Login(),
    new News.News(),
  ];
}

// ignore: non_constant_identifier_names
List<Widget> VPlanAppViews({bool loggedIn = true}) {
  return <Widget>[
    new RPlan.RPlanViewWidget(),
    loggedIn ? new User.User() : new Login.Login(),
  ];
}