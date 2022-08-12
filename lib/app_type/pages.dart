import 'package:flutter/material.dart';

import '../Views/Calendar.dart'	as Calendar; // ignore: library_prefixes
import '../Views/Home.dart'      as Home; // ignore: library_prefixes
import '../Views/HomeworkPage.dart' as Homework; // ignore: library_prefixes
import '../Views/Login.dart'     as Login; // ignore: library_prefixes
import '../Views/News.dart'      as News; // ignore: library_prefixes
import '../Views/RPlan.dart'     as RPlan; // ignore: library_prefixes
import '../Views/User.dart'      as SPlan; // ignore: library_prefixes
import '../Views/WebMail.dart'   as WebMail; // ignore: library_prefixes

import 'app_type_managment.dart';

IconData getPageIcon(AppPage page) {
  switch (page) {
    case AppPage.HOME:
      return Icons.home;
    case AppPage.CALENDAR:
      return Icons.event;
    case AppPage.NEWS:
      return Icons.public;
    case AppPage.LOGIN:
      return Icons.person;
    case AppPage.SPLAN:
      return Icons.widgets;
    case AppPage.RPLAN:
      return Icons.swap_horiz;
    case AppPage.HOMEWORK:
      return Icons.home_work_outlined;
    case AppPage.WEBMAIL:
      return Icons.mail;
    default:
      return Icons.question_mark;
  }
}

String getPageName(AppPage page) {
  switch (page) {
    case AppPage.HOME:
      return "Home";
    case AppPage.CALENDAR:
      return "Termine";
    case AppPage.NEWS:
      return "News";
    case AppPage.LOGIN:
      return "Login";
    case AppPage.SPLAN:
      return "SPlan";
    case AppPage.RPLAN:
      return "VPlan";
    case AppPage.HOMEWORK:
      return "Aufgaben";
    case AppPage.WEBMAIL:
      return "Mail";
    default:
      return "?";
  }
}

Widget getPageWidget(AppPage page) {
  switch (page) {
    case AppPage.HOME:
      return Home.Home();
    case AppPage.CALENDAR:
      return Calendar.Calendar();
    case AppPage.NEWS:
      return News.News();
    case AppPage.LOGIN:
      return Login.Login();
    case AppPage.SPLAN:
      return SPlan.User();
    case AppPage.RPLAN:
      return RPlan.RPlanViewWidget();
    case AppPage.HOMEWORK:
      return Homework.HomeworkView();
    case AppPage.WEBMAIL:
      return WebMail.WebMail();
    default:
      return Container();
  }
}