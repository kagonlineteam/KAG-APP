import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/api_models.dart';
import '../dynimports/apifile/dynapifile.dart'
if (dart.library.html) '../dynimports/apifile/webapifile.dart'
if (dart.library.io) '../dynimports/apifile/mobileapifile.dart' as apifile;
import 'helpers.dart';
import 'user.dart';


// ignore: must_be_immutable
class TimeTable extends StatelessWidget {

  // This should only exists until class is saved in api and processed there
  // Klasse is only set for non-Oberstufe.
  final String klasse;

  final bool isTeacher;

  TimeTable(this.klasse, {this.isTeacher = false});

  SPlan currentData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: klasse != null ? API.of(context).requests.getClassSPlan(klasse) : API.of(context).requests.getUserSPlan(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          currentData = snapshot.data;
          return TimeTableView(currentData, isTeacher: isTeacher, hideTeacher: true);
        } else if (snapshot.hasError)  {
          return Center(child: Text("Der Stundenplan konnte nicht geladen werden."));
        }
        return WaitingWidget();
    });
  }

}

class TimeTableView extends StatelessWidget {

  final SPlan splan;

  final bool isTeacher;
  final bool hideTeacher;

  TimeTableView(this.splan, {this.isTeacher = false, this.hideTeacher = false});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width <= SPLAN_PHONE_WIDTH) {
      return TabBarView(
        children: [1,2,3,4,5].map((day) =>
            ListView(children: splan.lessons.where((e) => e.dayOfWeek == day).map((e) =>
                TimeTableListEntry(e, isTeacher: isTeacher, hideTeacher: hideTeacher)
            ).toList())
        ).toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [1,2,3,4,5].map((day) =>
            Container(child: ListView(children: splan.lessons.where((e) => e.dayOfWeek == day).map((e) =>
                TimeTableListEntry(e, isTeacher: isTeacher, hideTeacher: hideTeacher)
            ).toList()), width: MediaQuery.of(context).size.width / 5)
        ).toList(),
      );
    }
  }

}


PreferredSizeWidget timeTableTabBar(BuildContext context, {bool isTablet = false}) {
  if (isTablet) {
    return PreferredSize(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TabletTimeTableDay("Montag"),
            TabletTimeTableDay("Dienstag"),
            TabletTimeTableDay("Mittwoch"),
            TabletTimeTableDay("Donnerstag"),
            TabletTimeTableDay("Freitag")
          ],
        ),
        preferredSize: Size.fromHeight(20)
    );
  } else {
    return TabBar(
      tabs: [
        Tab(text: "Mo"),
        Tab(text: "Di"),
        Tab(text: "Mi"),
        Tab(text: "Do"),
        Tab(text: "Fr") ,
      ],
    );
  }
}

class TimeTablePage extends StatelessWidget {

  final SPlan splan;

  final bool isTeacher;

  TimeTablePage(this.splan, {this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = splan.pdf != null ? [
      Padding(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(onPressed: () => apifile.openFile(context, splan.pdf, "application/pdf"), child: Text("Als PDF", style: TextStyle(color: Colors.white))),
      )
    ] : [];
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > SPLAN_PHONE_WIDTH) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Stundenplan"),
            bottom: timeTableTabBar(context, isTablet: true),
            actions: actions,
          ),
          body: TimeTableView(splan, isTeacher: isTeacher),
        );
      } else {
        int weekday = DateTime.now().weekday - 1;
        return DefaultTabController(length: 5, initialIndex: weekday > 4 ? 0 : weekday, child: Scaffold(
          appBar: AppBar(
            title: Text("Stundenplan"),
            bottom: timeTableTabBar(context),
            actions: actions,
          ),
          body: TimeTableView(splan, isTeacher: isTeacher),
        ));
      }
    });

  }

}

// Open Page functions
// We assume in both functions that only teachers can open a plan as a page
// so we do not have to check if the user is a teacher.
// If this ever changes we would have to check it here

void openRoomPlanPage(BuildContext context, String room) {
  API.of(context).requests.getRoomSPlan(room).then((splan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeTablePage(splan, isTeacher: true)),
    );
  });
}

void openClassPlanPage(BuildContext context, String klasse) {
  API.of(context).requests.getClassSPlan(klasse).then((splan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeTablePage(splan, isTeacher: true)),
    );
  });
}

// Smaller components

class TimeTableListEntry extends StatelessWidget {

  final Lehrstunde lehrstunde;
  final bool isTeacher;
  final bool hideTeacher;

  const TimeTableListEntry(this.lehrstunde, {this.isTeacher = false, this.hideTeacher = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(lehrstunde.course),
      subtitle: Text(
          lehrstunde.room +
              // We check for null and empty string to avoid the , showing in Bereitschaftsstunden
              (isTeacher && lehrstunde.klasse != null && lehrstunde.klasse.isNotEmpty ? ", ${lehrstunde.klasse}" : "") +
              // We do check isTeacher here to avoid a situation where a mistake in the API could be exposed
              (isTeacher && lehrstunde.teacher != null && !hideTeacher ? ", ${lehrstunde.teacher}" : "")
      ),
      leading: Container(
          padding: EdgeInsets.fromLTRB(15,5,15,5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              border: Border.all(width: 2)
          ),
          child: Text(lehrstunde.period.toString(), style: TextStyle(fontSize: 25))),
      onTap: () {
        if (isTeacher) {
          showDialog(context: context, builder: (context) => Dialog(
            child: IntrinsicHeight(
                child: Column(children: [
                  ListTile(
                    title: Text("Raumplan anzeigen"),
                    onTap: () {
                      Navigator.pop(context);
                      openRoomPlanPage(context, lehrstunde.room);
                    },
                  ),
                  ListTile(
                    title: Text("Klassenplan anzeigen"),
                    onTap: () {
                      Navigator.pop(context);
                      openClassPlanPage(context, lehrstunde.klasse);
                    },
                  )
                ])),
          ),
          );
        }
      },
    );
  }

}

class TabletTimeTableDay extends StatelessWidget {

  final String _day;

  TabletTimeTableDay(this._day);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                right: BorderSide(
                    color: Colors.white
                ),
                left: BorderSide(
                    color: Colors.white
                ),
                top: BorderSide(
                    color: Colors.white
                )
            )
        ),
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(_day, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

}