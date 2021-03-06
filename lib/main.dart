import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'Views/Views.dart';
import 'api/api.dart';
import 'api/api_helpers.dart';
import 'components/menu.dart';
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
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) => Color.fromRGBO(0, 82, 1, 1))
              )
            )
          ),
          home: KAGApp(),
        ), api),
  );
  if (!kIsWeb) {
    new PushNotificationsManager().init();
  }
}

class KAGApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return KAGAppState();
  }

}

class KAGAppState extends State<KAGApp> with SingleTickerProviderStateMixin {
  static final _isVPlanApp = kIsWeb && webinfo.window.location.host.startsWith("vplan.");
  static KAGAppState app;
  bool loggedIn = true;
  TabController controller;


  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: _isVPlanApp ? 0 : 2, length: _isVPlanApp ? 2 : 5, vsync: this);
    API.of(context).hasLoginCredentials().then((loggedIn) => setState(() => this.loggedIn = loggedIn));
  }

  KAGAppState(){
    app = this;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _isVPlanApp ? 2 : 5,
      child: Scaffold(
          body: TabBarView(
            controller: controller,
            children: _isVPlanApp ? VPlanAppViews(loggedIn: loggedIn) : AppViews(loggedIn: loggedIn),
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomNavigationBarMenu(controller: controller, isVPlanApp: _isVPlanApp)
        //backgroundColor: Colors.green,
      ),
    );


  }

  void setLoggedOut() {
    setState(() => loggedIn = false);
  }

  void setLoggedIn() {
    setState(() => loggedIn = true);
  }

  void goToPage(int page) {
    if (page == 3 && _isVPlanApp) page = 1;
    if (page == 2 && _isVPlanApp) page = 0;
    controller.animateTo(page);
  }
}