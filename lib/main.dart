import 'dart:io';
import 'dart:js';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'Views/Calendar.dart';
import 'Views/Login.dart';
import 'Views/News.dart';
import 'Views/PrivacyInformation.dart';
import 'api/api.dart';
import 'api/api_helpers.dart';
import 'api/api_models.dart';
import 'api/api_raw.dart';
import 'app_type/app_type_managment.dart';
import 'app_type/views.dart';
import 'components/home.dart';
import 'components/menu.dart';
import 'components/news.dart';
import 'dynimports/webinfo.dart' if (dart.library.html) 'dart:html' as webinfo;
import 'push_notifications.dart';

void main() async {
  // This does not need to be waited on as we do not use it in HomeScreen
  initializeDateFormatting("de_DE");
  Intl.defaultLocale = "de_DE";

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
            fontFamily: 'Zen Maru Gothic',
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
          routes: {
            '/impressum': (context) => PrivacyInformation(),
            '/kalender': (context) => Calendar(),
            '/login': (context) => Login(),
            //'/artikeldetail': (context) => ArticleDetail(originArticle),
          },
        ), api),
  );
  // Push Notification Stuff
  if (PushNotificationsManager.isPushPlatform()) {
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
}

class KAGApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return KAGAppState();
  }

}

class KAGAppState extends State<KAGApp> with TickerProviderStateMixin {
  AppTypeState _type = getDefaultAppType();
  GlobalKey _key = GlobalKey();
  static KAGAppState app;
  TabController controller;


  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: 0, length: _type.length, vsync: this); // If you change something here change it in build, too.
    API.of(context).hasLoginCredentials().then((loggedIn) => {
      if (loggedIn) {
        setState(() => type = getLoggedInAppType(API.of(context).requests.getUserInfo()))
      }
    });
  }

  KAGAppState(){
    app = this;
  }

  @override
  Widget build(BuildContext context) {
    if (_type.length != controller.length) {
      controller = TabController(initialIndex: controller.index, length: _type.length, vsync: this);
    }
    if (MediaQuery.of(context).size.width > 700 || (!kIsWeb && Platform.isMacOS)) { //  !kIsWeb is required to not cause an exception by calling Platform on web.
      return Row(
        key: _key,
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
            destinations: getNavigationRail(_type.pages),
          ),
          VerticalDivider(thickness: 2, width: 2, color: Theme.of(context).colorScheme.secondary),
          // This is the main content.
          Expanded(
            child: IndexedStack(
              index: controller.index,
              children: _type.getAppViews(),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
          key: _key,
          body: TabBarView(
            controller: controller,
            children: _type.getAppViews(),
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomNavigationBarMenu(_type.pages, controller)
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
      type = getLoggedInAppType(API.of(context).requests.getUserInfo());
    });
  }

  void goToPage(AppPage page) {
    setState(() {
      controller.animateTo(_type.getPageNumber(page));
    });
  }

  static AppTypeState getDefaultAppType() {
    AppType type = AppType.LOGGED_OUT;
    if (kIsWeb) {
      if (webinfo.window.location.host.startsWith("vplan.")) type =  AppType.VPLAN_LOGGED_OUT;
      if (webinfo.window.location.host.startsWith("m.")) type = AppType.MOBILE_SITE;
    }
    return getStateForUser(type, null);
  }

  static AppTypeState getLoggedInAppType(KAGUser user) {
    if (kIsWeb) {
      if (webinfo.window.location.host.startsWith("vplan.")) return getStateForUser(AppType.VPLAN, user);
    }
    return getStateForUser(AppType.NORMAL, user);
  }

  AppType get appType => _type.appType;

  AppTypeState get type => _type;

  set type (AppTypeState type) {
    _type = type;
    _key = GlobalKey();
  }
}