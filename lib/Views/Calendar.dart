import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      child: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                color: Color.fromRGBO(47, 109, 29, 1),
                margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                width: 100,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text("1"),
                    ),
                    Container(
                      child: Image.asset("assets/arrow.png"),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text("2"),
                    )
                  ],
                ),

              )
            ],
          )
        ],
      )
    );
  }

}