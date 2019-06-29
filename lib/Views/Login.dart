import 'dart:io';

import '../main.dart';
import '../api.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  TextEditingController password = new TextEditingController(),
      username = new TextEditingController();

  Future login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: new Dialog(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            new Text("Logging in..."),
          ],
        ),
      ),
    );
    bool success =
        await KAGApp.api.setLoginCredentials(username.text, password.text);
    Navigator.pop(context);
    if (success) {
      KAGApp.app.setLoggedIn();
    } else {
      showDialog(
          context: context,
          child: new SimpleDialog(
            title: Text("Login nicht möglich"),
            children: <Widget>[
              Center(
                child: Text(
                    "Konnte Login nicht durchführen. Ist dein Benutzername oder Passwort falsch?"),
              ),
              MaterialButton(
                onPressed: () => launch('https://kag-langenfeld.de/user/password'),
                child: Text("Passwort vergessen?"),
              ),
              MaterialButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Erneut versuchen."),
              )
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = new TextStyle(
        fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white);
    TextStyle hintTextStyle = new TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 20.0,
        color: new Color.fromRGBO(200, 200, 200, 1));

    final usernameField = TextField(
      controller: username,
      style: textStyle,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Username",
        hintStyle: hintTextStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );

    final passwordField = TextField(
      controller: password,
      style: textStyle,
      obscureText: true,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          hintStyle: hintTextStyle,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color.fromRGBO(0, 84, 1, 1),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: login,
        child: Text("Login",
            textAlign: TextAlign.center,
            style: textStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Container(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover)),
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 45.0),
                usernameField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButton,
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialButton(onPressed: () => KAGApp.tabs.animateTo(4), child: Text("Bitte logge dich ein!")),
    );
  }
}
