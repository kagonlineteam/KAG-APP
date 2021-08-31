import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Views/User.dart';
import '../dynimports/apifile/dynapifile.dart'
if (dart.library.html) '../dynimports/apifile/webapifile.dart'
if (dart.library.io) '../dynimports/apifile/mobileapifile.dart' as file;
import 'timetable.dart';

const int SPLAN_PHONE_WIDTH = 800;

class UserPage extends StatelessWidget {
  UserPage(this.shownName, this.timeTable, {this.isTeacher = false});

  final Widget timeTable;
  final String shownName;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    int weekday = DateTime.now().weekday - 1;
    return LayoutBuilder(builder: (context, constraints) {
      return constraints.maxWidth <= SPLAN_PHONE_WIDTH ?
      // Phone Rendering
      DefaultTabController(length: 5, initialIndex: weekday > 4 ? 0 : weekday, child: Scaffold(
        appBar: AppBar(actions: [UserMenu(isTeacher: isTeacher)],
          title: Text(shownName != null ? shownName : ""),
          bottom: timeTableTabBar(context),
        ),
        body: timeTable,
      ))
          :
      // Tablet Rendering
      Scaffold(
        appBar: AppBar(actions: [UserMenu(isTeacher: isTeacher)],
          title: Text(shownName != null ? shownName : ""),
          bottom: timeTableTabBar(context, isTablet: true),
        ),
        body: timeTable,
      );
    });
  }
}

class UserMenu extends StatelessWidget {

  final bool isTeacher;

  const UserMenu({this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == "logout") {
          User.logout(context);
        } else if (value.startsWith("openPDF:")) {
          String pdf = value.split(":")[1];
          file.openFile(context, pdf, "application/pdf");
        } else if (value == "roomplan") {
          _openRoomDialog(context);
        } else if (value == "classplan") {
          _openClassDialog(context);
        }
      },
      itemBuilder: (context) {
        var items = [
          PopupMenuItem(
            value: "logout",
            child: Text("Abmelden"),
          )
        ];
        String pdf = context.findAncestorWidgetOfExactType<User>().timeTable.currentData == null
            ? null
            : context.findAncestorWidgetOfExactType<User>().timeTable.currentData.pdf;
        if (pdf != null) {
          items.insert(0, PopupMenuItem(
            value: "openPDF:$pdf",
            child: Text("Stundenplan als PDF"),
          ));
        }
        if (isTeacher) {
          items.insert(0, PopupMenuItem(
            value: "roomplan",
            child: Text("Einen Raumplan öffnen"),
          ));
          items.insert(1, PopupMenuItem(
            value: "classplan",
            child: Text("Einen Stundenplan öffnen"),
          ));
        }
        return items;
      },
    );
  }

}

void _openRoomDialog(BuildContext context) {
  TextEditingController controller = TextEditingController();
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text("Bitte Raumnummer eingeben. z.B. A105"),
            CupertinoTextField(
              controller: controller,
            ),
          ],
        ),
        actions: [
          CupertinoButton(child: Text("Öffnen"), onPressed: () {
            Navigator.pop(context);
            openRoomPlanPage(context, controller.text);
          })
        ],
      ),
      barrierDismissible: true,
      context: context
  );
}

void _openClassDialog(BuildContext context) {
  TextEditingController controller = TextEditingController();
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text("Bitte Klasse eingeben. z.B. 7c oder Q2"),
            CupertinoTextField(
              controller: controller,
              maxLength: 2,
            ),
          ],
        ),
        actions: [
          CupertinoButton(child: Text("Öffnen"), onPressed: () {
            Navigator.pop(context);
            openClassPlanPage(context, controller.text);
          })
        ],
      ),
      barrierDismissible: true,
      context: context
  );
}