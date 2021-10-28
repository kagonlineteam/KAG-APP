import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'Views/Views.dart';
import 'api/api.dart';
import 'api/api_helpers.dart';
import 'components/menu.dart';
import 'dynimports/webinfo.dart' if (dart.library.html) 'dart:html' as webinfo;
import 'push_notifications.dart';


void main() async {
  // This does not need to be waited on as we do not use it in HomeScreen
  initializeDateFormatting("de_DE");

  // Preload binary messenger to load Shared Preferences
  WidgetsFlutterBinding.ensureInitialized();

  API api = new API();
  await api.preloadUserData(); // Load user data, that is required to build some app functions

  runApp(
    APIHolder(
        MaterialApp(
          title: 'KAG',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Color.fromRGBO(0, 112, 1, 1),
            appBarTheme: AppBarTheme(
              color: const Color.fromRGBO(0, 112, 1, 1)
            ),
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
  new PushNotificationsManager().init();
}

class KAGApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return KAGAppState();
  }

}

class KAGAppState extends State<KAGApp> with TickerProviderStateMixin {
  static final _isVPlanApp = kIsWeb && webinfo.window.location.host.startsWith("vplan.");
  static KAGAppState app;
  bool loggedIn = true;
  bool webmailTab = false; // This is calculated here and just passed to Widgets, to have it the same everywhere.
  TabController controller;


  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: _isVPlanApp ? 0 : 2, length: _getPageCount(), vsync: this); // If you change something here change it in build, too.
    API.of(context).hasLoginCredentials().then((loggedIn) => setState(() => this.loggedIn = loggedIn));
    webmailTab = loggedIn && API.of(context).requests.getUserInfo().mailConsent; // Is also in setLoggedIn
  }

  KAGAppState(){
    app = this;
  }

  @override
  Widget build(BuildContext context) {
    if (_getPageCount() != controller.length) {
      controller = TabController(initialIndex: controller.index, length: _getPageCount(), vsync: this);
    }
    if ((kIsWeb && MediaQuery.of(context).size.width > 700) || (!kIsWeb && Platform.isMacOS)) {
      return Row(
        children: [
          NavigationRail(
            selectedIndex: controller.index,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).accentColor
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).accentColor
            ),
            groupAlignment: 0,
            onDestinationSelected: (index) {
              setState(() {
                controller.index = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: getNavigationRail(_isVPlanApp, webmailTab),
          ),
          VerticalDivider(thickness: 2, width: 2, color: Theme.of(context).accentColor),
          // This is the main content.
          Expanded(
            child: IndexedStack(
              index: controller.index,
              children: _isVPlanApp ? VPlanAppViews(loggedIn: loggedIn) : AppViews(loggedIn: loggedIn, webmail: webmailTab),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
          body: TabBarView(
            controller: controller,
            children: _isVPlanApp ? VPlanAppViews(loggedIn: loggedIn) : AppViews(loggedIn: loggedIn, webmail: webmailTab),
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomNavigationBarMenu(controller: controller, isVPlanApp: _isVPlanApp, webmail: webmailTab)
      );
    }
  }

  void setLoggedOut() {
    setState(() {
      loggedIn = false;
      webmailTab = false;
    });
  }

  void setLoggedIn() {
    setState(() {
      loggedIn = true;
      webmailTab = loggedIn && API.of(context).requests.getUserInfo().mailConsent; // Is also in initState
    });
  }

  void goToPage(int page) {
    if (page == 3 && _isVPlanApp) page = 1;
    if (page == 2 && _isVPlanApp) page = 0;
    setState(() {
      controller.animateTo(page);
    });
  }

  int _getPageCount() {
    return _isVPlanApp ? 2 : (webmailTab ? 6 : 5);
  }
}