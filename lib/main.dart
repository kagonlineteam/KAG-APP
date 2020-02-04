import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './Views/Calendar.dart'	as Calendar;
import './Views/Home.dart'      as Home;
import './Views/Login.dart'     as Login;
import './Views/RPlan.dart'     as RPlan;
import './Views/User.dart'      as User;
import './Views/News.dart'      as News;
import 'api.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'KAG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF2f6d1d,
          <int, Color>{
            50: Color.fromRGBO(47, 109, 29, 1),
            100: Color.fromRGBO(47, 109, 29, 1),
            200: Color.fromRGBO(47, 109, 29, 1),
            300: Color.fromRGBO(47, 109, 29, 1),
            400: Color.fromRGBO(47, 109, 29, 1),
            500: Color.fromRGBO(47, 109, 29, 1),
            600: Color.fromRGBO(47, 109, 29, 1),
            700: Color.fromRGBO(47, 109, 29, 1),
            800: Color.fromRGBO(47, 109, 29, 1),
            900: Color.fromRGBO(47, 109, 29, 1),
          },
        ),
      ),
      home: KAGApp(),
    ),
  );
}

class KAGApp extends StatefulWidget {
  static final API api = new API();
  static FlutterLocalNotificationsPlugin notificationsPlugin;
  static KAGAppState app;

  static Future _holidayNotification() async {
    notificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
      // ignore: missing_return
        onDidReceiveLocalNotification: (param, param1, param2, param3) {});
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    notificationsPlugin.initialize(initializationSettings,
        // ignore: missing_return
        onSelectNotification: (param) {});
    var time = (await ((await api.getAPIRequest(APIAction.GET_CALENDAR))
        .getHolidayUnixTimestamp())) *
        1000;
    if (time > DateTime.now().millisecondsSinceEpoch) {
      var scheduledNotificationDateTime =
      new DateTime.fromMillisecondsSinceEpoch(time);
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'holidayKAG',
          'KAG Holiday Channel',
          'KAG will send you a Holiday Notification.');
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await notificationsPlugin.cancelAll();
      await notificationsPlugin.schedule(
          0,
          'Ferien',
          'Viel Spaß in den Ferien!',
          scheduledNotificationDateTime,
          platformChannelSpecifics);
    }
  }

  @override
  State<StatefulWidget> createState() {
    _holidayNotification();
    app = KAGAppState();
    return app;
  }
}

class KAGAppState extends State<KAGApp> with TickerProviderStateMixin {
  static int _index = 0;
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: KAGAppState._index, length: 5, vsync: this);
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
      length: 5,
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
              tabs: <Widget>[
                Tab(
                  text: "Home",
                  icon: Icon(Icons.home),
                ),
                Tab(
                  text: "VPlan",
                  icon: Icon(Icons.compare_arrows),
                ),
                Tab(
                  text: "Termine",
                  icon: Icon(Icons.event),
                ),
                Tab(text: "News", icon: Icon(Icons.public),),
                Tab(
                  text: "User",
                  icon: Icon(Icons.person),
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
  var tabContents;

  Future setLoggedIn() async {
    setState(() {
      tabContents = <Widget>[
        new Home.Home(),
        new RPlan.RPlan(),
        new Calendar.Calendar(),
        new News.News(),
        new User.User()
      ];
    });
  }

  Future checkLogin() async {
    if ((await KAGApp.api.getAPIRequest(APIAction.GET_USERNAME)) == null) {
      setState(() {
        tabContents = <Widget>[
          new Home.Home(),
          new Login.NotLoggedIn(),
          new Calendar.Calendar(),
          new News.News(),
          new Login.Login()
        ];
      });
    }
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