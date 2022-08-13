import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/api_models.dart';
import '../components/helpers.dart';
import '../components/homework.dart';

class HomeworkView extends StatefulWidget {
  HomeworkPage createState() => HomeworkPage();
}

class HomeworkPage extends State<HomeworkView> {
  List<Homework> homeworks;
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hausaufgaben"),
      ),
      body: RefreshIndicator(
        onRefresh: loadHomeworks,
        child: FutureBuilder (
          key: key,
          future: API.of(context).requests.getMyHomeworks(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              homeworks = snapshot.data;
              return ListView(
                children: homeworks.map((h) => HomeworkCard(h)).toList(),
              );
            } else if (snapshot.hasError)  {
              return Center(child: Text("Die Hausaufgaben konnten nicht geladen werden."));
            }
            return WaitingWidget();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateHomework()));
            loadHomeworks();
          },
          child: Icon(Icons.add,
              size: 30, color: Color.fromRGBO(255, 255, 255, 1))),
    );
  }

  static HomeworkPage of(BuildContext context) {
    return context.findAncestorStateOfType<HomeworkPage>();
  }

  Future<void> loadHomeworks() async {
    var newHomeworks = await API.of(context).requests.getMyHomeworks();
    setState(() {
      homeworks = newHomeworks;
      key = GlobalKey();
    });
  }
}

class CreateHomework extends StatefulWidget {
  _CreateHomeworkState createState() => _CreateHomeworkState();
}

class _CreateHomeworkState extends State<CreateHomework> {
  String task = "", course = "";
  DateTime deadline = DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hausaufgabe erstellen")),
      body: Container(
          margin: EdgeInsets.all(20),
          child: ListView(physics: ClampingScrollPhysics(), children: [
            TextFormField(
                decoration: InputDecoration(labelText: "Kurs"),
                maxLines: 1,
                initialValue: '',
                onChanged: (value) => {course = value}),
            TextFormField(
                decoration: InputDecoration(labelText: "Aufgabe"),
                maxLines: 1,
                initialValue: '',
                onChanged: (value) => {task = value}),
            Container(
              child: Text("Muss erledigt werden bis:",
                  style: TextStyle(fontSize: 16)),
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            ),
            // The unconstrained Box needs
            // to exist so that ListView does
            // not stretch the sized box
            UnconstrainedBox(
              child: SizedBox(
                height: 400,
                width: 500,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: deadline,
                  onDateTimeChanged: (newDateTime) {
                    setState(() {
                      deadline = newDateTime;
                    });
                  },
                  minimumDate: _getTodayDateTime(),
                  maximumDate: DateTime.now().add(Duration(days: 100)),
                ),
              ),
            )
          ])),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save,
              size: 30, color: Color.fromRGBO(255, 255, 255, 1)),
          onPressed: () async {
            if (task.isEmpty || course.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(API.of(context).requests.getUserInfo().useSie ?
                  "Bitte geben Sie den Kurs und eine Aufgabe ein" :
                  "Bitte gebe Fach/Kurs und eine Aufgabe an.")
              ));
              return;
            }
            await API.of(context).requests.addHomework(
                course, task, deadline.millisecondsSinceEpoch ~/ 1000);
            Navigator.pop(context);
          }),
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
      appBar: AppBar(title: Text("Hausaufgabe bearbeiten")),
      body: Container(
          margin: EdgeInsets.all(20),
          child: ListView(physics: ClampingScrollPhysics(), children: [
            Text(homework.course, style: TextStyle(fontSize: 20)),
            TextFormField(
                decoration: InputDecoration(labelText: "Aufgabe"),
                maxLines: 1,
                initialValue: homework.task,
                onChanged: (value) => {homework.task = value}),
            Container(
              child: Text("Muss erledigt werden bis:",
                  style: TextStyle(fontSize: 16)),
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            ),
            // This is to prevent non valid times to be non reportable
            homework.deadlineDatetime
                    .isBefore(DateTime.now().add(Duration(days: 100)))
                ?
                // The unconstrained Box needs
                // to exist so that ListView does
                // not stretch the sized box
                UnconstrainedBox(
                    child: SizedBox(
                    height: 400,
                    width: 500,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: homework.deadlineDatetime,
                      onDateTimeChanged: (newDateTime) {
                        setState(() => {
                              homework.deadline =
                                  newDateTime.millisecondsSinceEpoch ~/ 1000
                            });
                      },
                      minimumDate: _getTodayDateTime(),
                      maximumDate: DateTime.now().add(Duration(days: 100)),
                    ),
                  ))
                : Text(
                    "Ungültiges Datum ${homework.deadlineDatetime.day}.${homework.deadlineDatetime.month}.${homework.deadlineDatetime.year}"),
          ])),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.report,
                size: 30, color: Color.fromRGBO(255, 255, 255, 1)),
            onPressed: () async {
              var didReport = await _reportWarning(context, homework.id);
              if (didReport) Navigator.pop(context, null);
            },
            backgroundColor: Colors.redAccent,
            heroTag: null,
          ),
          Container(
            width: 20,
          ),
          FloatingActionButton(
            child: Icon(Icons.save,
                size: 30, color: Color.fromRGBO(255, 255, 255, 1)),
            onPressed: () async {
              if (homework.task.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(API.of(context).requests.getUserInfo().useSie ?
                    "Bitte geben Sie eine Aufgabe ein" :
                    "Bitte gebe eine Aufgabe an.")
                ));
                return;
              }
              await API.of(context).requests.editHomework(homework.id,
                  homework.course, homework.task, homework.deadline);
              Navigator.pop(context, homework);
            },
            heroTag: null,
          ),
        ],
      ),
    );
  }

  Future _reportWarning(BuildContext context, int id) {
    return showCupertinoDialog(
        builder: (context) => CupertinoAlertDialog(
              content: Text(
                  'Bitte eine Hausaufgabe nur melden, wenn dort Dinge geschrieben werden, die nichts mit Hausaufgaben zu tun haben. Bei falschen Informationen kann man die Hausaufgabe bearbeiten. Wenn die Hausaufgabe gemeldet wird, wird sich ein Admin diese ansehen.',
                  style: TextStyle(fontSize: 15)),
              actions: [
                CupertinoButton(
                    child:
                        Text("Hausaufgabe melden", textAlign: TextAlign.left),
                    onPressed: () async {
                      await API.of(context).requests.reportHomework(id);
                      Navigator.pop(context, true);
                    }),
                CupertinoButton(
                    child: Text("Abbrechen", textAlign: TextAlign.left),
                    onPressed: () {
                      Navigator.pop(context, false);
                    })
              ],
            ),
        barrierDismissible: true,
        context: context);
  }
}

DateTime _getTodayDateTime() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}