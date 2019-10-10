import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {

  static const dateStyle = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold);
  static const descriptionStyle = const TextStyle(fontSize: 15);
  var usableWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    usableWidth = width - 132;

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
                      "Termine",
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
        ),
        body: SafeArea(
            child: ListView(
              children: <Widget>[
                _generateRow(),
                _generateRow(),
                _generateRow()
              ],
            )
        )
    );
  }

  Widget _generateRow() {
    //Placeholder
    var dateOneText     = "10.11";
    var dateTwoText     = "11.11";
    var titleText       = "Title";
    var descriptionText = "Description";

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  width: 2
              )
          )
      ),
      child: Row(
        children: <Widget>[
          Container(
            color: Color.fromRGBO(47, 109, 29, 1),
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            width: 100,
            height: 120,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(dateOneText, style: dateStyle),
                ),
                Container(
                  child: Image.asset("assets/arrow.png"),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(dateTwoText, style: dateStyle),
                )
              ],
            ),

          ),
          Container(
            height: 120,
            width: usableWidth,
            margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(titleText, style: titleStyle),
                  alignment: Alignment.topLeft,
                  height: 40,
                ),
                Container(
                  child: Text(descriptionText,
                      style: descriptionStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4
                  ),
                  alignment: Alignment.topLeft,
                  height: 70,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}