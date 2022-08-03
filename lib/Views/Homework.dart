import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/api_models.dart';
import '../components/homework.dart';

class HomeworkWidget extends StatefulWidget {
  _HomeworkWidgetState createState() => _HomeworkWidgetState();
}

class _HomeworkWidgetState extends State<HomeworkWidget> {
  List<Homework> homeworks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hausaufgaben"),
      ),
      body: FutureBuilder (
        future: API.of(context).requests.getMyHomeworks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            homeworks = snapshot.data;
            return ListView.builder(
              itemCount: homeworks.length,
              itemBuilder: (context, index) {
                return HomeworkCard(homeworks[index]);
              },
            );
          }
          return Center(
            child: Text('Es konnten keine Hausaufgaben geladen werden'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateHomework()))
        },
        child: Icon(Icons.add, size: 30, color: Color.fromRGBO(255, 255, 255, 1))
      ),
    );
  }

  _loadNewHomeworks(BuildContext context) async {
    var newHomeworks = await API.of(context).requests.getMyHomeworks();
    setState(() => {
      homeworks = newHomeworks
    });
  }
}