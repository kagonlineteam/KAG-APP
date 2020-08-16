import 'package:flutter/material.dart';
import 'rplan_components.dart';

class RPlanTabBar extends StatelessWidget {
  RPlanTabBar(this._days);

  final List<DayWidget> _days;

  Widget build(BuildContext context) {
    return DefaultTabController(length: _days.length, child: TabBarView(
      children: _days.map((day) => TabBarDay(day)).toList(),
    ));
  }
}

class RPlanListView extends StatelessWidget {
  RPlanListView(this._days);

  final List<DayWidget> _days;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("VPlan"), actions: [TeacherKuerzelButton()]),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: ListView(
          children: _days.map((day) => ListViewDay(day)).toList(),
        ),
      ),
    );
  }

}