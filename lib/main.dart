import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api.dart';

import './Views/Home.dart' as Home;
import './Views/RPlan.dart' as RPlan;
import './Views/Calendar.dart' as Calendar;
import './Views/News.dart' as News;
import './Views/User.dart' as User;
import './Views/Login.dart' as Login;

void main() => runApp(KAGApp());

class KAGApp extends StatelessWidget {
  static final API api = new API();
  static TabController tabs;
  static _HomePageState app;
  static FlutterLocalNotificationsPlugin notificationsPlugin;

  static Future _holidayNotification() async {
    notificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: (param, param1, param2, param3) {});
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (param) {});
    var time = (await ((await api.getAPIRequest(APIAction.GET_CALENDAR)).getHolidayUnixTimestamp())) * 1000;
    if (time > DateTime.now().millisecondsSinceEpoch) {
      var scheduledNotificationDateTime = new DateTime.fromMillisecondsSinceEpoch(time);
      var androidPlatformChannelSpecifics =
      new AndroidNotificationDetails('holidayKAG',
          'KAG Holiday Channel', 'KAG will send you a Holiday Notification.');
      var iOSPlatformChannelSpecifics =
      new IOSNotificationDetails();
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


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAG',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor(
          0xFF2f6d1d,
          <int, Color>{
            50:  Color.fromRGBO(47, 109, 29, 1),
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
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }

}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() {
    KAGApp._holidayNotification();
    KAGApp.app = _HomePageState();
    return KAGApp.app;
  }
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{

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

  @override
  Widget build(BuildContext context) {
    KAGApp.tabs = new TabController(length: 5, vsync: this);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: TabBarView(
            controller: KAGApp.tabs,
            children: tabContents,
            physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          color: Color.fromRGBO(244, 244, 244, 1),
          child: TabBar(
            controller: KAGApp.tabs,
            tabs: <Widget>[
              Tab(text: "Home", icon: Icon(Icons.home),),
              Tab(text: "VPlan", icon: Icon(Icons.compare_arrows),),
              Tab(text: "Termine", icon: Icon(Icons.event),),
              Tab(text: "Aktuelles", icon: Icon(Icons.public),),
              Tab(text: "User", icon: Icon(Icons.person),),
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

  @override
  void dispose() {
    KAGApp.tabs.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setLoggedIn();
    checkLogin();
  }


}
