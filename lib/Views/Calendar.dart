import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {

  static const dateStyle = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold);
  static const descriptionStyle = const TextStyle(fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Aktuelles",
                      style: TextStyle(fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
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
                        child: Text("10.10", style: dateStyle),
                      ),
                      Container(
                        child: Image.asset("assets/arrow.png"),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text("11.10", style: dateStyle),
                      )
                    ],
                  ),

                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text("Title", style: titleStyle),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.black)
                        ),
                      ),
                      Container(
                        child: Text("Description", style: descriptionStyle),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1.0, color: Colors.blue)
                        ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2.0, color: Colors.green)
                  ),
                )
              ],
            )
          ],
        )
    )
    );
  }

}