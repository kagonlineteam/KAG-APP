import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Views/User.dart';
import '../api/api.dart' as api;

class UserPage extends StatelessWidget {
  UserPage(this.shownName, this.timeTable);

  final Widget timeTable;
  final String shownName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [UserMenu()],
          title: Text(shownName != null ? shownName : ""),
      ),
      body: Visibility(
          visible: timeTable != null,
          child: Center(
              child: Container(
                child: Container(
                  child: timeTable,
                  margin: EdgeInsets.all(10),
                ),
                color: Colors.white,
                constraints: BoxConstraints.expand(),
              )
          )
      ),
    );
  }
}

class UserMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == "mail") {
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
                                  Text(mailInfos.exists ? "Das neue Passwort ist:" : "Wir haben wir Dir/Ihnen für den Mailaccount ein extra Passwort erstellt. Mit diesem ist nur der Login für WebMail oder SMTP/IMAP möglich."),
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
        } else if (value == "webmail") {
          launch("https://mailhost.kag-langenfeld.de/SoGO");
        } else if (value == "logout") {
          User.logout(context);
        }
      },
      itemBuilder: (context) {
        return [
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
      },
    );
  }

}