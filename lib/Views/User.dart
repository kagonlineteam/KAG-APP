import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../main.dart';

class User extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }
}

class UserState extends State<User> with AutomaticKeepAliveClientMixin<User> {
  String name = "";
  Widget timeTable = Row();
  bool U;
  String plan = "", uKlasse = "";

  void logout() {
    KAGApp.api.setLoginCredentials(null, null);
    KAGApp.app.setLoggedOut();
    SharedPreferences.getInstance().then((instance) => instance.remove("klasse"));
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Logged out!"),
        action: SnackBarAction(
            label: 'Zurück zum Start!', onPressed: () => KAGApp.app.goToPage(2))
    ));
  }

  Future _load() async {
    KAGApp.api.getAPIRequest(APIAction.GET_USER_INFO).then((request) async {
      String response = await request.getUserInfo();
      var userInfo = jsonDecode(response)['entity'];
      if (userInfo.containsKey("stufe")) {
        plan = userInfo['stufe'];
      }

      // Set Timetable
      if (userInfo.containsKey("stufe") &&
          (userInfo['stufe'] == "EF" ||
              userInfo['stufe'] == "Q1" ||
              userInfo['stufe'] == "Q2")) {
         _setTimeTable();
      }

        if(userInfo.containsKey("stufe") &&
            (userInfo['stufe'] == "5" ||
                userInfo['stufe'] == "6" ||
                userInfo['stufe'] == "7" ||
                userInfo['stufe'] == "8" ||
                userInfo['stufe'] == "9" ) ) {
          var preferences = await SharedPreferences.getInstance();
          if (preferences.containsKey("klasse")) {
            plan += preferences.getString("klasse");
            _setTimeTable();
          } else {
            setState(() {
              timeTable = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: TextField(
                        enabled: true,
                        maxLength: 1,
                        maxLengthEnforced: true,
                        style: new TextStyle(color: Theme.of(context).accentColor),
                        onChanged: (klasse){
                          uKlasse = klasse;
                        }
                    ),
                    padding: EdgeInsets.fromLTRB(100, 100, 100, 10),
                  ),
                  Container(
                    child: Text("Bitte gebe den Buchstaben deinen Klasse ein (z.B.: a)"),
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                        child: Text("Bestätigen", style: TextStyle(color: Colors.white),),
                        onPressed: () {
                          plan += uKlasse;
                          _setTimeTable();
                          SharedPreferences.getInstance().then((instance) => instance.setString("klasse", uKlasse));
                        }
                    ),
                    padding: EdgeInsets.all(50),
                  )
                ],
              );
            });
          }
        }


      // Set Name
      if (userInfo.containsKey("stufe")) {
        // Student
        name = userInfo['firstname'];
      } else {
        // Teacher
        name = userInfo['lastname'];
      }
    });
  }

  void _setTimeTable() {
    setState(() {
      timeTable = GestureDetector(
        onTap: () => launch(
            "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$plan.pdf"),
        child: OrientationBuilder(builder: (context, orientation) {
          return Image.network(
          "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$plan.pdf.png",
            //height: MediaQuery.of(context).size.height - 100,
          );
        }),
      );
    });
  }


  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
      return new Scaffold(
          appBar: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Align(
                    child: Text(name,
                        style: TextStyle(fontSize: 30)),
                    alignment: Alignment.centerLeft,
                  ),
                  RaisedButton(
                    onPressed: logout,
                    child: Text("Abmelden",
                        style: TextStyle(
                            fontSize: 15, color: Colors.white)),
                  )
                ],
              ),
            ),

          ),
          body: Center(
              child: Container(
                child: Container(
                  child: timeTable,
                  margin: EdgeInsets.all(10),
                ),
                color: Colors.white,
                constraints: BoxConstraints.expand(),
              )
          )
      );
    }


  @override
  bool get wantKeepAlive => true;
}
