import 'package:flutter/material.dart';
import '../api/api.dart';
import '../api/api_helpers.dart';
import '../api/api_models.dart';
import 'helpers.dart';


class TimeTable extends StatelessWidget {

  // This should only exists until class is saved in api and processed there
  // Klasse is only set for non-Oberstufe.
  final String klasse;

  const TimeTable(this.klasse);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: klasse != null ? API.of(context).requests.getClassSPlan(klasse) : API.of(context).requests.getUserSPlan(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TimeTableView(snapshot.data);
        } else if (snapshot.hasError)  {
          return Center(child: Text("Der Stundenplan konnte nicht geladen werden."));
        }
        return WaitingWidget();
    });
  }

}

class TimeTableView extends StatelessWidget {

  final SPlan splan;

  TimeTableView(this.splan);

  //apifile.openFile(splan.file); öffnet die PDF

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: splan.lessons.map((e) => ListTile(title: Text(e.course), subtitle: Text("${e.period}. Stunde, ${getWeekdayByNumber(e.dayOfWeek)}, ${e.room}"),leading: Icon(Icons.school))).toList(),
    );
  }

}