import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_models.dart';
import '../main.dart';
import '../push_notifications.dart';
import 'RPlan.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login>
    with AutomaticKeepAliveClientMixin<Login> {
  TextEditingController password = new TextEditingController(),
      username = new TextEditingController();

  Future login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            new Text("Anmelden"),
          ],
        ),
      )
    );
    bool success =
        await API.of(context).setLoginCredentials(username.text, password.text);
    Navigator.pop(context);
    if (success) {
      KAGUser userInfo = API.of(context).requests.getUserInfo();
      if (userInfo.isTeacher && userInfo.kuerzel != null) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString(RPlan.SP_FILTER, userInfo.kuerzel);
      }
      if (FirebaseMessaging.instance != null) FirebaseMessaging.instance.subscribeToTopic(PushNotificationsManager.TOPIC_LOGGED_IN); // the messages sent are still public. This is only to annoy less people
      KAGAppState.app.setLoggedIn();
      KAGAppState.app.goToPage(0);
    } else {
      showDialog(
          context: context,
          builder: (context) => new CupertinoAlertDialog(
            title: Text("Login nicht möglich"),
            content: Text(
                "Konnte Login nicht durchführen.\n Ist dein Benutzername oder Passwort falsch?\n Bitte achte auf die Groß- und Kleinschreibung (z.b. MMax16)"),
            actions: <Widget>[
              MaterialButton(
                onPressed: () =>
                    launch('https://kag-langenfeld.de/user/password'),
                child: Text("Passwort vergessen?"),
              ),
              MaterialButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Erneut versuchen"),
              )
            ],
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    TextStyle textStyle = new TextStyle(color: Colors.white);
    TextStyle hintTextStyle =
        new TextStyle(color: new Color.fromRGBO(150, 150, 150, 1));

    final usernameField = Container(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: TextField(
          controller: username,
          decoration: InputDecoration.collapsed(
              hintText: "Benutzername", hintStyle: hintTextStyle),
          style: textStyle,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white))),
    );

    final passwordField = Container(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: TextField(
          controller: password,
          obscureText: true,
          decoration: InputDecoration.collapsed(
            hintText: "Passwort",
            hintStyle: hintTextStyle,
          ),
          style: textStyle,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white))),
    );

    final loginButton = Padding(
      padding: const EdgeInsets.only(left: 35, right: 35),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).colorScheme.primary,
        child: MaterialButton(
            onPressed: login,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            minWidth: MediaQuery.of(context).size.width,
            child: Container(
              child: Text("Anmelden", style: textStyle),
            )),
      ),
    );

    var inputs = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 45.0),
        usernameField,
        SizedBox(height: 25.0),
        passwordField,
        SizedBox(height: 35.0),
        loginButton,
        SizedBox(height: 6.0),
        MaterialButton(
          onPressed: () => launch('https://kag-langenfeld.de/user/password'),
          child: Text("Passwort vergessen?", style: const TextStyle(color: Colors.grey),),
        ),
        SizedBox(height: 15.0),
      ],
    );

    bool isTablet = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: isTablet ? AssetImage("assets/background-login.jpg") : AssetImage("assets/background.png"),
                fit: BoxFit.cover)
        ),
        padding: EdgeInsets.all(20),
        child: Center(
          child: isTablet ? Container(
            padding: const EdgeInsets.fromLTRB(70, 35, 70, 5),
            width: 500,
            height: 300,
            color: Theme.of(context).backgroundColor.withOpacity(0.9),
            child: inputs,
          ) : inputs,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
