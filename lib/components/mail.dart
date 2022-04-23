import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
// File import (3 lines)
import '../dynimports/apifile/dynapifile.dart'
if (dart.library.html) '../dynimports/apifile/webapifile.dart'
if (dart.library.io) '../dynimports/apifile/mobileapifile.dart' as file;

class WebmailMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == "mail") {
          _openMailDialog(context);
        } else if (value == "mailconfig") {
          _openMailiOSConfig(context);
        } else if (value == "apppassword") {
          _generateAppPasswordPrompt(context);
        }
      },
      itemBuilder: (context) {
        var items = [
          PopupMenuItem(
            value: "mail",
            child: Text(API.of(context).requests.getUserInfo().useSie ? "Ihr Mail Account" : "Dein Mail Account"),
          ),
          PopupMenuItem(
            value: "apppassword",
            child: Text("App Passwort generieren"),
          ),
          if (kIsWeb || Platform.isIOS)
            PopupMenuItem(
              value: "mailconfig",
              child: Text("Mail in iOS/MacOS installieren"),
            )
        ];
        return items;
      },
    );
  }
}

// This is used if the Webmail can not be embedded
class MailMenu extends StatelessWidget {

  static const TextStyle style = const TextStyle(fontSize: 40);

  @override
  Widget build(BuildContext context) {
    var buttons = [
      Column(
        ElevatedButton(onPressed: () => launch("https://webmail.kag-langenfeld.de"), child: Text("Webmail öffnen", style: style)),
        ElevatedButton(onPressed: () => _openMailDialog(context), child: Text(API.of(context).requests.getUserInfo().useSie ? "Ihr Mail Account" : "Dein Mail Account", style: style)),
        ElevatedButton(
            onPressed: () => _generateAppPasswordPrompt(context),
            child: Text("App Passwort generieren", style: style)
        ),
        if (kIsWeb || Platform.isIOS)
          ElevatedButton(onPressed: () => _openMailiOSConfig(context), child: Text(kIsWeb ? "MacOS/iOS Konfiguration generieren" : "Konfiguration installieren", style: style))
      ],
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buttons,
        ),
      );
    }
}

void _openMailDialog(BuildContext context) {
  API.of(context).requests.getMailSettings().then((mailInfos) {
    if (mailInfos.consent) {
      print(API.of(context).requests.getUserInfo().mailPasswordConsent);
      showCupertinoDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            actions: [
              CupertinoButton(child: Text("Abbruch"), onPressed: () => Navigator.pop(context)),
              Visibility(
                child: CupertinoButton(
                    child: Text("App Passwort erstellen"),
                    onPressed: () => _generateAppPasswordPrompt(context)
                ),
                visible: mailInfos.exists,
              ),
              if (!mailInfos.exists || API.of(context).requests.getUserInfo().mailPasswordConsent) CupertinoButton(
                  child: Text(mailInfos.exists ? "Neues Passwort" : "Mail erstellen"),
                  onPressed: () {
                    if (API.of(context).requests.getUserInfo().mailPasswordConsent) {
                      API.of(context).requests.resetMailPassword().then((newPassword) => _showNewMailPassword(context, newPassword, mailInfos.exists ? null : mailInfos.primaryMail));
                    } else { // New account
                      API.of(context).requests.resetMailPassword().then((_) => _showNewMailAccount(context, mailInfos.primaryMail));
                    }
                  }
              )
            ],
            content: Column(
              children: [
                Text("Mail Infos:"),
                Text(mailInfos.exists ? mailInfos.primaryMail : (API.of(context).requests.getUserInfo().useSie ? "Sie müssen erst eine Mail erstellen" : "Du musst erst eine Mail erstellen")),
                Visibility(
                  visible: mailInfos.exists,
                  child: Text(API.of(context).requests.getUserInfo().useSie ?
                  "Mit \"App Passwort erstellen\" können Sie ein Passwort für ein Mail Programm oder iPad generieren." :
                  "Mit \"App Passwort erstellen\" kannst du ein Passwort für ein Mail Programm generieren."),
                )
              ],
            ),

          ));
    } else {
      showCupertinoDialog(
          builder: (context) => CupertinoAlertDialog(
            content: Text("Wir können dir leider keine Mailadresse erstellen, solange Du nicht den Mail Bogen im Sekretariat abgegeben hast. Solltest du den bereits vor über einer Woche abgegeben haben melde dich bitte bei support@kag-langenfeld.de"),
            actions: [
              CupertinoButton(child: Text("OK"), onPressed: () => Navigator.pop(context))
            ],
          ),
          barrierDismissible: true,
          context: context
      );
    }
  });
}

void _generateAppPasswordPrompt(BuildContext bcontext) {
  DateTime date = DateTime.now().add(Duration(days: 365));
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text(
                API.of(context).requests.getUserInfo().useSie ?
                "Bitte wählen Sie unten das Ablaufdatum für das App-Passwort durch drehen der Auswahlräder." :
                "Bitte wähle das Ablaufdatum für das App-Passwort."
            ),
            SizedBox(
              height: 400,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: date,
                onDateTimeChanged: (newDateTime) {
                  date = newDateTime;
                },
                minimumDate: DateTime.now().add(Duration(days: 1)),
                maximumYear: 2037, // Yes we should someday prepare ourselves for 2k36
              ),
            )
          ],
        ),
        actions: [
          CupertinoButton(child: Text("App Passwort erstellen", textAlign: TextAlign.left), onPressed: () {
            int time = (date.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
            Navigator.pop(context);
            API.of(bcontext).requests.getMailAppPassword(expireSeconds: time).then((newPassword) => _showNewMailPassword(bcontext, newPassword, null));
          }),
          CupertinoButton(child: Text("Permanentes App Passwort erstellen", textAlign: TextAlign.left, style: TextStyle(color: Colors.grey)), onPressed: () {
            Navigator.pop(context);
            API.of(bcontext).requests.getMailAppPassword().then((newPassword) => _showNewMailPassword(bcontext, newPassword, null));
          })
        ],
      ),
      barrierDismissible: true,
      context: bcontext
  );
}

void _showNewMailPassword(BuildContext context, String password, String newMail) {
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text(newMail == null ? "Das neue Passwort ist:" : (
                API.of(context).requests.getUserInfo().useSie ?
                "Wir haben Ihnen für den Mailaccount ein extra Passwort erstellt. Mit diesem ist nur der Login für die alte WebMail oder SMTP/IMAP möglich. Ihre Mail Adresse ist $newMail. Für Mailprogramme/iPads muss ein App Passwort generiert werden" :
                "Wir haben Dir für den Mailaccount ($newMail ein extra Passwort erstellt. Für Mailprogramme muss jedoch ein App Passwort generiert werden"
            )),
            Stack(
              children: [
                CupertinoTextField(
                  controller: TextEditingController(text: password),
                  readOnly: true,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: CupertinoButton(
                      child: Icon(Icons.copy, size: 15),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: password));
                      }
                  ),
                )
              ],
            )
          ],
        ),
        actions: [
          CupertinoButton(child: Text("OK"), onPressed: () => Navigator.pop(context))
        ],
      ),
      barrierDismissible: true,
      context: context
  );
}

void _showNewMailAccount(BuildContext context, String newMail) {
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text(API.of(context).requests.getUserInfo().useSie ?
                "Wir haben Ihnen einen Mailaccount erstellt. Ihre Mail Adresse ist $newMail. Für Mailprogramme/iPads muss ein App Passwort generiert werden. Außerdem kann die Webmail in der App und unter webmail.kag-langenfeld.de genutzt werden." :
                "Wir haben Dir einen Mailaccount mit der Adresse $newMail erstellt. Um Mailprogramme und Schüler-iPads zu verbinden musst Du ein App Passwort generieren. Ansonsten kannst du auch die Webmail in der App nutzen."
            )
          ],
        ),
        actions: [
          CupertinoButton(child: Text("OK"), onPressed: () => Navigator.pop(context))
        ],
      ),
      barrierDismissible: true,
      context: context
  );
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
          CupertinoButton(child: Text("OK"), onPressed: () {
            API.of(context).requests.getIOSMailConfig().then((config) => file.openIOSConfigFile(context, config.config));
            Navigator.pop(context);
          })
        ],
      ),
      context: context
  );
}