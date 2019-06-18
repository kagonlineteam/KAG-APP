import 'package:flutter/material.dart';

import 'api.dart';

import './Views/Home.dart' as Home;
import './Views/RPlan.dart' as RPlan;
import './Views/Calendar.dart' as Calendar;
import './Views/News.dart' as News;
import './Views/User.dart' as User;

void main() => runApp(KAGApp());

class KAGApp extends StatelessWidget {
  static final API api = new API();
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
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: TabBarView(
            children: <Widget>[
              new Home.Home(),
              new RPlan.RPlan(),
              new Calendar.Calendar(),
              new News.News(),
              new User.User()
            ]
        ),
        bottomNavigationBar: Container(
          color: Color.fromRGBO(244, 244, 244, 1),
          child: TabBar(
            tabs: <Widget>[
              Tab(text: "Home", icon: Icon(Icons.home),),
              Tab(text: "VPlan", icon: Icon(Icons.compare_arrows),),
              Tab(text: "Termine", icon: Icon(Icons.event),),
              Tab(text: "KAGtuell", icon: Icon(Icons.public),),
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
}
