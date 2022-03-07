import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
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
            colorScheme: ColorScheme(
              primary: Color.fromRGBO(0, 112, 1, 1),
              background: Color.fromRGBO(47, 47, 47, 1),
              secondary: Color.fromRGBO(255, 145, 10, 1),
              onSecondary: Color.fromRGBO(255, 145, 10, 1),
              brightness: Brightness.light,
              error: Colors.red,
              onError: Colors.white,
              onBackground: Color.fromRGBO(255, 145, 10, 1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white
            ),
            backgroundColor: Color.fromRGBO(47, 47, 47, 1),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) => Color.fromRGBO(0, 82, 1, 1))
              )
            )
          ),
          home: KAGApp(),
        ), api),
  );
  // Push Notification Stuff
  PushNotificationsManager pushNotificationsManager = new PushNotificationsManager();
  pushNotificationsManager.init().then((_) {
    if (FirebaseMessaging.instance != null) {
      FirebaseMessaging.instance.subscribeToTopic(PushNotificationsManager.TOPIC_ALL);
      api.hasLoginCredentials().then((value) {
        // the messages sent are still public. This is only to annoy less people
        // similar code in Views/Login.dart
        if (value) {
          FirebaseMessaging.instance.subscribeToTopic(PushNotificationsManager.TOPIC_LOGGED_IN);
          if (api.requests.getUserInfo().isAppDev) FirebaseMessaging.instance.subscribeToTopic(PushNotificationsManager.TOPIC_APP_DEV);
        } else {
          FirebaseMessaging.instance.unsubscribeFromTopic(PushNotificationsManager.TOPIC_LOGGED_IN);
          FirebaseMessaging.instance.unsubscribeFromTopic(PushNotificationsManager.TOPIC_APP_DEV);
        }
      });
    }
  });
}

class KAGApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return KAGAppState();
  }

}

enum AppType {
  LOGGED_OUT,
  NORMAL,
  NORMAL_WITH_WEBMAIL,
  VPLAN_LOGGED_OUT,
  VPLAN,
  MOBILE_SITE
}

class KAGAppState extends State<KAGApp> with TickerProviderStateMixin {
  AppType type = getDefaultAppType();
  static KAGAppState app;
  TabController controller;


  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: 0, length: getPageCount(type), vsync: this); // If you change something here change it in build, too.
    API.of(context).hasLoginCredentials().then((loggedIn) => {
      if (loggedIn) {
        setState(() => type = getLoggedInAppType(webmail: API.of(context).requests.getUserInfo().mailConsent))
      }
    });
  }

  KAGAppState(){
    app = this;
  }

  @override
  Widget build(BuildContext context) {
    if (getPageCount(type) != controller.length) {
      controller = TabController(initialIndex: controller.index, length: getPageCount(type), vsync: this);
    }
    if (MediaQuery.of(context).size.width > 700 || (!kIsWeb && Platform.isMacOS)) { //  !kIsWeb is required to not cause an exception by calling Platform on web.
      return Row(
        children: [
          NavigationRail(
            selectedIndex: controller.index,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.secondary
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary
            ),
            groupAlignment: 0,
            onDestinationSelected: (index) {
              setState(() {
                controller.index = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: getNavigationRail(type),
          ),
          VerticalDivider(thickness: 2, width: 2, color: Theme.of(context).colorScheme.secondary),
          // This is the main content.
          Expanded(
            child: IndexedStack(
              index: controller.index,
              children: AppViews(type),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
          body: TabBarView(
            controller: controller,
            children: AppViews(type),
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomNavigationBarMenu(type, controller)
      );
    }
  }

  void setLoggedOut() {
    setState(() {
      type = getDefaultAppType();
    });
  }

  void setLoggedIn() {
    setState(() {
      type = getLoggedInAppType(webmail: API.of(context).requests.getUserInfo().mailConsent);
    });
  }

  void goToPage(int page) {
    setState(() {
      controller.animateTo(page);
    });
  }

  static AppType getDefaultAppType() {
    if (kIsWeb) {
      if (webinfo.window.location.host.startsWith("vplan.")) return AppType.VPLAN_LOGGED_OUT;
      if (webinfo.window.location.host.startsWith("m.")) return AppType.MOBILE_SITE;
      return AppType.LOGGED_OUT;
    }
    return AppType.LOGGED_OUT;
  }

  static AppType getLoggedInAppType({bool webmail = false}) {
    if (kIsWeb) {
      if (webinfo.window.location.host.startsWith("vplan.")) return AppType.VPLAN;
    }
    return webmail ? AppType.NORMAL_WITH_WEBMAIL : AppType.NORMAL;
  }
}