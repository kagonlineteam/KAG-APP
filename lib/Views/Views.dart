import 'package:flutter/cupertino.dart';

import './Calendar.dart'	as Calendar; // ignore: library_prefixes
import './Home.dart'      as Home; // ignore: library_prefixes
import './Login.dart'     as Login; // ignore: library_prefixes
import './News.dart'      as News; // ignore: library_prefixes
import './RPlan.dart'     as RPlan; // ignore: library_prefixes
import './User.dart'      as User; // ignore: library_prefixes
import './WebMail.dart'   as WebMail; // ignore: library_prefixes

import '../main.dart';

/// Used by main.dart
///

// ignore: non_constant_identifier_names
List<Widget> AppViews(AppType type) {
  switch (type) {
    case AppType.LOGGED_OUT:
      return <Widget>[
        new Home.Home(),
        new Calendar.Calendar(),
        new News.News(),
        new Login.Login(),
      ];
    case AppType.NORMAL:
    case AppType.NORMAL_WITH_WEBMAIL:
      return <Widget>[
        new Home.Home(),
        new Calendar.Calendar(),
        new RPlan.RPlanViewWidget(),
        new User.User(),
        if (type == AppType.NORMAL_WITH_WEBMAIL) WebMail.WebMail(),
        new News.News(),
      ];
    case AppType.VPLAN_LOGGED_OUT:
      return <Widget>[
        new Login.Login(),
      ];
    case AppType.VPLAN:
      return <Widget>[
        new RPlan.RPlanViewWidget(),
        new User.User(),
      ];
    case AppType.MOBILE_SITE:
      return <Widget>[
        new News.News(),
        new Calendar.Calendar(),
        new Login.Login(),
      ];
  }

  return <Widget>[];
}

int getPageCount(AppType type) {
  switch (type) {
    case AppType.LOGGED_OUT:
      return 4;
      break;
    case AppType.NORMAL:
      return 5;
      break;
    case AppType.NORMAL_WITH_WEBMAIL:
      return 6;
      break;
    case AppType.VPLAN_LOGGED_OUT:
      return 1;
      break;
    case AppType.VPLAN:
      return 2;
      break;
    case AppType.MOBILE_SITE:
      return 3;
      break;
  }
  return 0;
}