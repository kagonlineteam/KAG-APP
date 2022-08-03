import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../api/api.dart';
import '../api/api_models.dart';
import '../Views/Homework.dart';

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
    if (result == null) return;
    else if (result == 'reported') {
      HomeworkWidget();
    }
    setState(() => {
      homework = result
    });
  }
}

class CreateHomework extends StatefulWidget {
  _CreateHomeworkState createState() => _CreateHomeworkState();
}

class _CreateHomeworkState extends State<CreateHomework> {

  String task, course;
  DateTime deadline = DateTime.now().add(Duration(days: 365));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hausaufgabe erstellen")
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Kurs"),
              //controller: controller,
              maxLines: 1,
              initialValue: '',
              onChanged: (value) => {
                course = value
              }
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Aufgabe"),
              //controller: controller,
              maxLines: 1,
              initialValue: '',
              onChanged: (value) => {
                task = value
              }
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
              child: ElevatedButton(
                child: Text("Deadline bearbeiten: ${deadline.day}.${deadline.month}.${deadline.year}"),
                onPressed: () => {
                  _datePicker(context, deadline)
                }
              )
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 100, right: 0, bottom: 0),
              child: ElevatedButton(
                child: Text('Hausaufgabe speichern', style: TextStyle(fontSize: 20)),
                onPressed: () async => {
                  await API.of(context).requests.addHomework(course, task, deadline.millisecondsSinceEpoch ~/ 1000),
                  Navigator.pop(context)
                }
              )
            )
          ]
        )
      )
    );
  }

  _datePicker(BuildContext context, initialDeadline) {
    showCupertinoDialog(
        builder: (context) => CupertinoAlertDialog(
          content: Column(
            children: [
              Text(
                  API.of(context).requests.getUserInfo().useSie ?
                  "Bitte wählen sie eine Deadline für die Hausaufgabe" :
                  "Bitte wähle eine Deadline für die Hausaufgabe"
              ),
              SizedBox(
                height: 400,
                width: 500, // TODO Ändern
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDeadline,
                  onDateTimeChanged: (newDateTime) {
                    setState(() => {
                      deadline = newDateTime
                    });
                  },
                  minimumDate: DateTime.now().add(Duration(days: 1)),
                  maximumYear: 2037, // Yes we should someday prepare ourselves for 2k36
                ),
              )
            ],
          ),
          actions: [
            CupertinoButton(child: Text("Neue Deadline festlegen", textAlign: TextAlign.left), onPressed: () {
              Navigator.pop(context);
            })
          ],
        ),
        barrierDismissible: true,
        context: context
    );
  }
}

class EditHomework extends StatefulWidget {
  EditHomework(this.homework);

  final Homework homework;

  _EditHomeworkState createState() => _EditHomeworkState(homework);
}

class _EditHomeworkState extends State<EditHomework> {
  _EditHomeworkState(this.homework);

  final Homework homework;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Hausaufgabe bearbeiten")
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Kurs"),
              //controller: controller,
              maxLines: 1,
              initialValue: homework.course,
              onChanged: (value) => {
                homework.course = value
              }
            ),
            TextFormField(
                decoration: InputDecoration(labelText: "Aufgabe"),
                //controller: controller,
                maxLines: 1,
                initialValue: homework.task,
                onChanged: (value) => {
                  homework.task = value
                }
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
              child: ElevatedButton(
                child: Text("Deadline bearbeiten: ${homework.deadlineDatetime.day}.${homework.deadlineDatetime.month}.${homework.deadlineDatetime.year}"),
                onPressed: () => {
                  _datePicker(context, homework.deadlineDatetime)
                }
              )
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
              child: ElevatedButton(
                child: Text("Hausaufgabe melden"),
                onPressed: () => {
                  _reportWarning(context, homework.id).then(() => {
                    Navigator.pop(context, 'reported')
                  })
                }
              )
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 100, right: 0, bottom: 0),
              child: ElevatedButton(
                child: Text('Hausaufgabe speichern', style: TextStyle(fontSize: 20)),
                onPressed: () async => {
                  await API.of(context).requests.editHomework(homework.id, homework.course, homework.task, homework.deadline),
                  Navigator.pop(context, homework)
                }
              )
            )
          ]
        )
      )
    );
  }

  _datePicker(BuildContext context, initialDeadline) {
    showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text(
              API.of(context).requests.getUserInfo().useSie ?
              "Bitte wählen sie eine Deadline für die Hausaufgabe" :
              "Bitte wähle eine Deadline für die Hausaufgabe"
            ),
            SizedBox(
              height: 400,
              width: 500, // TODO Ändern
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDeadline,
                onDateTimeChanged: (newDateTime) {
                  setState(() => {
                    homework.deadline = newDateTime.millisecondsSinceEpoch ~/ 1000
                  });
                },
                minimumDate: DateTime.now().add(Duration(days: 1)),
                maximumYear: 2037, // Yes we should someday prepare ourselves for 2k36
              ),
            )
          ],
        ),
        actions: [
          CupertinoButton(
            child: Text("Neue Deadline festlegen", textAlign: TextAlign.left),
            onPressed: () {
              Navigator.pop(context);
            }
          )
        ],
      ),
      barrierDismissible: true,
      context: context
    );
  }

  _reportWarning(BuildContext context, int id) {
    showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Text('Wenn die Hausaufgabe gemeldet wird, kann nur noch ein Lehrer die Hausaufgabe sehen und bearbeiten.', style: TextStyle(fontSize: 20)),
        actions: [
          CupertinoButton(
            child: Text("Hausaufgabe melden", textAlign: TextAlign.left),
            onPressed: () {
              API.of(context).requests.reportHomework(id);
              Navigator.pop(context);
            }
          )
        ],
      ),
      barrierDismissible: true,
      context: context
    );
  }
}