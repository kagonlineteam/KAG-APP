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
          API.of(context).requests.getMailAppPassword().then((newPassword) => _showNewMailPassword(context, newPassword, null));
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
          )
        ];
        if (kIsWeb || Platform.isIOS) {
          items.insert(2, PopupMenuItem(
            value: "mailconfig",
            child: Text("Mail in iOS/MacOS installieren"),
          ));
        }
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
      ElevatedButton(onPressed: () => launch("https://webmail.kag-langenfeld.de"), child: Text("Webmail öffnen", style: style)),
      ElevatedButton(onPressed: () => _openMailDialog(context), child: Text(API.of(context).requests.getUserInfo().useSie ? "Ihr Mail Account" : "Dein Mail Account", style: style)),
      ElevatedButton(
          onPressed: () => API.of(context).requests.getMailAppPassword().then((newPassword) => _showNewMailPassword(context, newPassword, null)),
          child: Text("App Passwort generieren", style: style)
      )
    ];
    if (kIsWeb || Platform.isIOS) {
      buttons.add(ElevatedButton(onPressed: () => _openMailiOSConfig(context), child: Text(API.of(context).requests.getUserInfo().useSie ? "Ihr Mail Account" : "Dein Mail Account", style: style)));
    }
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
      showCupertinoDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            actions: [
              CupertinoButton(child: Text("Abbruch"), onPressed: () => Navigator.pop(context)),
              Visibility(
                child: CupertinoButton(
                    child: Text("App Passwort erstellen"),
                    onPressed: () => API.of(context).requests.getMailAppPassword().then((newPassword) => _showNewMailPassword(context, newPassword, null))
                ),
                visible: mailInfos.exists,
              ),
              CupertinoButton(
                  child: Text(mailInfos.exists ? "Neues Passwort" : "Mail erstellen"),
                  onPressed: () => API.of(context).requests.resetMailPassword().then((newPassword) => _showNewMailPassword(context, newPassword, mailInfos.exists ? null : mailInfos.primaryMail))
              )
            ],
            content: Column(
              children: [
                Text("Mail Infos:"),
                Text(mailInfos.exists ? mailInfos.primaryMail : (API.of(context).requests.getUserInfo().useSie ? "Sie müssen erst eine Mail erstellen" : "Du musst erst eine Mail erstellen")),
                Visibility(
                  visible: mailInfos.exists,
                  child: Text(API.of(context).requests.getUserInfo().useSie ?
                  "Über \"Neues Passwort\" können Sie Ihr Mail Passwort zurücksetzen. Über \"App Passwort erstellen\" können Sie ein Passwort für ein Mail Programm oder iPad generieren." :
                  "Über \"Neues Passwort\" können kannst Du Mail Passwort zurücksetzen. Über \"App Passwort erstellen\" kannst du ein Passwort für ein Mail Programm generieren."),
                )
              ],
            ),

          ));
    } else {
      showCupertinoDialog(
          builder: (context) => CupertinoAlertDialog(
            content: Text("Wir können dir leider keine Mailadresse erstellen, solange du nicht den Mail Bogen im Sekretariat abgegeben hast."),
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

void _showNewMailPassword(BuildContext context, String password, String newMail) {
  Navigator.pop(context);
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          children: [
            Text(newMail == null ? "Das neue Passwort ist:" : (
                API.of(context).requests.getUserInfo().useSie ?
                "Wir haben wir Ihnen für den Mailaccount ein extra Passwort erstellt. Mit diesem ist nur der Login für die alte WebMail oder SMTP/IMAP möglich. Deine Mail Adresse ist $newMail. Für Mailprogramme/iPads muss ein App Passwort generiert werden" :
                "Wir haben wir Dir für den Mailaccount ein extra Passwort erstellt. Für Mailprogramme muss jedoch ein App Passwort generiert werden"
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