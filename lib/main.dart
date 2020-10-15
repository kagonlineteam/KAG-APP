// ignore_for_file: library_prefixes
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';
import 'package:kag/api/api_helpers.dart';

import './Views/Calendar.dart'	as Calendar;
import './Views/Home.dart'      as Home;
import './Views/Login.dart'     as Login;
import './Views/News.dart'      as News;
import './Views/RPlan.dart'     as RPlan;
import './Views/User.dart'      as User;

import 'api/api.dart';

import 'dynimports/webinfo.dart' if (dart.library.html) 'dart:html' as webinfo;
import 'push_notifications.dart';


void main() {
  // This does not need to be waited on as we do not use it in HomeScreen
  initializeDateFormatting("de_DE");

  API api = new API();
  //TODO preload
  runApp(
    APIHolder(
        MaterialApp(
          title: 'KAG',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Color.fromRGBO(0, 112, 1, 1),
            accentColor: Color.fromRGBO(255, 145, 10, 1),
            backgroundColor: Color.fromRGBO(47, 47, 47, 1),
            buttonColor: Color.fromRGBO(0, 82, 1, 1),
          ),
          home: KAGApp(),
        ), api),
  );
  if (!kIsWeb) {
    new PushNotificationsManager().init();
  }
}

class KAGApp extends StatefulWidget {
  static KAGAppState app;

  @override
  State<StatefulWidget> createState() {
    app = KAGAppState();
    return app;
  }
}

class KAGAppState extends State<KAGApp> with TickerProviderStateMixin {
  static final _isVPlanApp = kIsWeb && webinfo.window.location.host.startsWith("vplan.");
  static int _index = _isVPlanApp ? 0 : 2; // ignore: prefer_final_fields
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: KAGAppState._index, length: _isVPlanApp ? 2 : 5, vsync: this);
    setLoggedIn();
    checkLogin();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
          length: _isVPlanApp ? 2 : 5,
          child: Scaffold(
              body: TabBarView(
                controller: controller,
                children: tabContents,
                physics: NeverScrollableScrollPhysics(),
              ),
              bottomNavigationBar: Container(
                color: Color.fromRGBO(244, 244, 244, 1),
                child: TabBar(
                  controller: controller,
                  tabs: _isVPlanApp ?
                  // VPlan App
                  <Widget>[
                    Tab(
                      text: "VPlan",
                      icon: Icon(Icons.compare_arrows),
                    ),
                    Tab(
                      text: "SPlan",
                      icon: Icon(Icons.person),
                    ),
                  ] :
                  // Normal App
                  <Widget>[
                    Tab(
                      text: "Termine",
                      icon: Icon(Icons.event),
                    ),
                    Tab(
                      text: "VPlan",
                      icon: Icon(Icons.compare_arrows),
                    ),
                    Tab(
                      text: "Home",
                      icon: Icon(Icons.home),
                    ),
                    Tab(
                      text: "User",
                      icon: Icon(Icons.person),
                    ),
                    Tab(
                      text: "News",
                      icon: Icon(Icons.public),
                    ),
                  ],
                  isScrollable: false,
                  labelColor: Color.fromRGBO(47, 109, 29, 1),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontSize: 10,
                  ),
                ),
              )
            //backgroundColor: Colors.green,
          ),
    );


  }
  List<Widget> tabContents;

  Future setLoggedIn() async {
    if (_isVPlanApp) {
      setState(() {
        tabContents = <Widget>[
          new RPlan.RPlanViewWidget(),
          new User.User(),
        ];
      });
    } else {
      setState(() {
        tabContents = <Widget>[
          new Calendar.Calendar(),
          new RPlan.RPlanViewWidget(),
          new Home.Home(),
          new User.User(),
          new News.News(),
        ];
      });
    }
  }

  void setLoggedOut() {
    if (_isVPlanApp) {
      setState(() {
        tabContents = <Widget>[
          new Login.NotLoggedIn(),
          new Login.Login(),
        ];
      });
    } else {
      setState(() {
        tabContents = <Widget>[
          new Calendar.Calendar(),
          new Login.NotLoggedIn(),
          new Home.Home(),
          new Login.Login(),
          new News.News(),
        ];
      });
    }
  }

  Future checkLogin() async {
    if (!(await API.of(context).hasLoginCredentials())) {
      setLoggedOut();
    } else {
      setLoggedIn();
    }
  }

  void goToPage(int page) {
    if (page == 3 && _isVPlanApp) page = 1;
    if (page == 2 && _isVPlanApp) page = 0;
    controller.animateTo(page);
  }
}

class DetailPage extends StatelessWidget {
  DetailPage(this.index);
  final int index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Detail page $index"),
      ),
    );
  }
}