import 'package:flutter/material.dart';
import '../Views/User.dart';

class UserPage extends StatelessWidget {
  UserPage(this.shownName, this.timeTable);

  final Widget timeTable;
  final String shownName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        Padding(
          padding: EdgeInsets.all(10),
          child: RaisedButton(
            onPressed: () => User.logout(context),
            child: Text("Abmelden",
                style: TextStyle(fontSize: 15, color: Colors.white)),
          ),
        )
      ], title: Text(shownName != null ? shownName : "")),
      body: Visibility(
          visible: timeTable != null,
          child: Center(
              child: Container(
                child: Container(
                  child: timeTable,
                  margin: EdgeInsets.all(10),
                ),
                color: Colors.white,
                constraints: BoxConstraints.expand(),
              )
          )
      ),
    );
  }
}
