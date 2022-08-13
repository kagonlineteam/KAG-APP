import 'package:flutter/material.dart';
import '../Views/HomeworkPage.dart';
import '../api/api_models.dart';

class HomeworkCard extends StatefulWidget {
  HomeworkCard(this.homework);

  final Homework homework;

  _HomeworkCardState createState() => _HomeworkCardState(homework);
}

class _HomeworkCardState extends State<HomeworkCard> {
  _HomeworkCardState(this.homework);

  Homework homework;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToEditScreen(context),
      child: Container(
        width: 400,
        margin: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                  child: Text(homework.course)
                ),
                Text(homework.task)
              ],
            ),
            Align(
              child: Text("Zuletzt bearbeitet von ${homework.author}"),
              alignment: Alignment.centerLeft
            ),
            Align(
              child: Text("Muss bis zum ${homework.deadlineDatetime.day}.${homework.deadlineDatetime.month}.${homework.deadlineDatetime.year} erledigt werden"),
              alignment: Alignment.centerLeft
            ),
          ]
        ),
      )
    );
  }

  void _navigateToEditScreen(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditHomework(homework)));
    if (result == null) {
      HomeworkPage.of(context).loadHomeworks();
      return;
    }
    setState(() => {
      homework = result
    });
  }
}