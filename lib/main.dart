import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kag/push_notifications.dart';

import './Views/Calendar.dart'	as Calendar;
import './Views/Home.dart'      as Home;
import './Views/Login.dart'     as Login;
import './Views/RPlan.dart'     as RPlan;
import './Views/User.dart'      as User;
import './Views/News.dart'      as News;
import 'api.dart';

import 'package:flutter/foundation.dart' show kIsWeb;


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
  if (!kIsWeb) {
    new PushNotificationsManager().init();
  }
}

class KAGApp extends StatefulWidget {
  static final API api = new API();
  static FlutterLocalNotificationsPlugin notificationsPlugin;
  static KAGAppState app;

  @override
  State<StatefulWidget> createState() {
    app = KAGAppState();
    return app;
  }
}

class KAGAppState extends State<KAGApp> with TickerProviderStateMixin {
  static int _index = 2;
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
  var tabContents;

  Future setLoggedIn() async {
    setState(() {
      tabContents = <Widget>[
        new Calendar.Calendar(),
        new RPlan.RPlan(),
        new Home.Home(),
        new User.User(),
        new News.News(),
      ];
    });
  }

  Future checkLogin() async {
    if ((await KAGApp.api.getAPIRequest(APIAction.GET_USERNAME)) == null) {
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