import 'package:flutter/material.dart';

const BorderSide splittingBorder      = const BorderSide(color: Color.fromRGBO(47, 109, 29, 1), width: 2);
Container splittingContainer    = Container(margin: EdgeInsets.fromLTRB(10, 0, 10, 0), decoration: BoxDecoration(border: Border(top: splittingBorder)));

// Used e.g. in RPlan
class ErrorTextHolder extends StatelessWidget {
  ErrorTextHolder(this._error, {this.barActions = const [], this.barTitle = ""});

  final String _error;
  final String barTitle;
  final List<Widget> barActions;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(actions: barActions, title: Text(barTitle)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(_error),
        ),
      ),
    );
  }

  String get error => _error;
}