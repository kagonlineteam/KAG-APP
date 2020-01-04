import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

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
      // ignore: deprecated_member_use
      child: new Dialog(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            new Text("Anmelden"),
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
          // ignore: deprecated_member_use
          child: new SimpleDialog(
            title: Text("Login nicht möglich"),
            children: <Widget>[
              Center(
                child: Text(
                    "Konnte Login nicht durchführen. Ist dein Benutzername oder Passwort falsch? Bitte achte auf die Groß- und Kleinschreibung (z.b. MMax16)"),
              ),
              MaterialButton(
                onPressed: () =>
                    launch('https://kag-langenfeld.de/user/password'),
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

    final loginButton = Material(
      borderRadius: BorderRadius.circular(30),
      color: Color.fromRGBO(47, 109, 29, 1),
      child: MaterialButton(
          onPressed: login,
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          child: Container(
            child: Text("Anmelden", style: textStyle),
          )),
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
                SizedBox(height: 35.0),
                loginButton,
                SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialButton(
          onPressed: () => KAGApp.app.controller.animateTo(4),
          child: Text("Bitte melde dich an!")),
    );
  }
}
