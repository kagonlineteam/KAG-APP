import 'package:flutter/material.dart';

class News extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Aktuelles",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              )
            ],
          )
          , body: SafeArea(
          child: Center(
            child: Text("Helllo"),
          )
      )
      );
  }

}