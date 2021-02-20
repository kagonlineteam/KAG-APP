
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Views/User.dart';
import '../api/api.dart' as api;
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
        if (value == "mail") {
          _openMailDialog(context);
        } else if (value == "webmail") {
          launch("https://mailhost.kag-langenfeld.de/SoGO");
        } else if (value == "mailconfig") {
          _openMailiOSConfig(context);
        } else if (value == "logout") {
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
            value: "mail",
            child: Text("Dein Mail Account"),
          ),
          PopupMenuItem(
            value: "webmail",
            child: Text("Webmail"),
          ),
          PopupMenuItem(
            value: "logout",
            child: Text("Abmelden"),
          )
        ];
        if (kIsWeb || Platform.isIOS) {
          items.insert(2, PopupMenuItem(
            value: "mailconfig",
            child: Text("Mail in iOS/MacOS installieren"),
          ));
        }
        String pdf = context.findAncestorWidgetOfExactType<User>().timeTable.currentData.pdf;
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


void _openMailDialog(BuildContext context) {
  api.API.of(context).requests.getMailSettings().then((mailInfos) {
    if (mailInfos.consent) {
      showCupertinoDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            actions: [
              CupertinoButton(child: Text("Abbruch"), onPressed: () => Navigator.pop(context)),
              CupertinoButton(child: Text(mailInfos.exists ? "Neues Passwort" : "Mail erstellen"), onPressed: () => api.API.of(context).requests.resetMailPassword().then((newPassword) {
                Navigator.pop(context);
                showCupertinoDialog(
                    builder: (context) => CupertinoAlertDialog(
                      content: Column(
                        children: [
                          Text(mailInfos.exists ? "Das neue Passwort ist:" : "Wir haben wir Dir/Ihnen für den Mailaccount ein extra Passwort erstellt. Mit diesem ist nur der Login für WebMail oder SMTP/IMAP möglich. Deine Mail Adresse ist ${mailInfos.primaryMail}"),
                          Stack(
                            children: [
                              CupertinoTextField(
                                controller: TextEditingController(text: newPassword),
                                readOnly: true,
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: CupertinoButton(
                                    child: Icon(Icons.copy, size: 15),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: newPassword));
                                    }
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    barrierDismissible: true,
                    context: context
                );
              }))
            ],
            content: Column(
              children: [
                Text("Mail Infos:"),
                Text(mailInfos.exists ? mailInfos.primaryMail : "Du/Sie musst/müssen erst eine Mail erstellen"),
              ],
            ),

          ));
    } else {
      showCupertinoDialog(
          builder: (context) => CupertinoAlertDialog(
            content: Text("Wir können dir leider keine Mailadresse erstellen, solange du nicht den Mail Bogen im Sekretariat abgegeben hast."),
          ),
          barrierDismissible: true,
          context: context
      );
    }
  });
}

void _openMailiOSConfig(BuildContext context) {
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text("Unter iOS muss die folgende Datei gespeichert werden und dann über die Dateien App geöffnet."),
            Text("Unter MacOS wird die Datei automatisch heruntergeladen und muss geöffnet werden.")
          ],
        ),
        actions: [
          CupertinoButton(child: Text("OK"), onPressed: () => api.API.of(context).requests.getIOSMailConfig().then((config) => file.openIOSConfigFile(context, config.config)))
        ],
      ),
      context: context
  );
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
          CupertinoButton(child: Text("Öffnen"), onPressed: () => openRoomPlanPage(context, controller.text))
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
          CupertinoButton(child: Text("Öffnen"), onPressed: () => openClassPlanPage(context, controller.text))
        ],
      ),
      barrierDismissible: true,
      context: context
  );
}