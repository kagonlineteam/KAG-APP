import 'dart:io';

import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }

}

class LoginState extends State<Login> {

  TextEditingController password = new TextEditingController(),
      username = new TextEditingController();

  void login() {

  }


  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = new TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white);
    TextStyle hintTextStyle = new TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: new Color.fromRGBO(200, 200, 200, 1));

    final usernameField = TextField(
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

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/background.png"), fit: BoxFit.cover)
          ),
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