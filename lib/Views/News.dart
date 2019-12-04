import 'package:flutter/material.dart';

// ignore: must_be_immutable
class News extends StatelessWidget {
  static const dateStyle = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle = const TextStyle(
      fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 1);
  static const descriptionStyle = const TextStyle(fontSize: 15);
  static const subTextStyle = const TextStyle(fontSize: 10);
  var usableWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    usableWidth = width - 132;

    return Scaffold(
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
                      style: TextStyle(
                          fontSize: 30,
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
          children: <Widget>[_generateRow(), _generateRow(), _generateRow()],
        )));
  }

  Widget _generateRow() {
    var title = "Title";
    var descriptionText =
        "Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description Description ";
    var date = "30.10.19";
    var author = "RJipps";

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(235, 235, 235, 1), width: 2))),
      child: GestureDetector(
          child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                color: Color.fromRGBO(200, 200, 200, 1),
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: 100,
                height: 100,
              ),
              Container(
                height: 100,
                width: usableWidth,
                margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(title, style: titleStyle),
                      alignment: Alignment.topLeft,
                      height: 40,
                    ),
                    Container(
                      child: Text(descriptionText,
                          style: descriptionStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3),
                      alignment: Alignment.topLeft,
                      height: 55,
                    )
                  ],
                ),
              )
            ],
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(author, style: subTextStyle),
                ),
                Container(
                  child: Text(date, style: subTextStyle),
                )
              ],
            ),
            margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
          )
        ],
      )),
    );
  }
}
