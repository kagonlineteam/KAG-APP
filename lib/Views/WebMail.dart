import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/api.dart';
import '../components/helpers.dart';
import '../components/mail.dart';

class WebMail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isMacOS || Platform.isLinux) {
      return Scaffold(
        appBar: AppBar(),
        body: MailMenu()
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Mails"),
        actions: [
          WebmailMenu()
        ],
      ),
      body: FutureBuilder(
        future: API.of(context).requests.getWebmailHash(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: "https://webmail.kag-langenfeld.de/?sso&hash=${snapshot.data}",
            );
          } else if (snapshot.hasError) {
            return ErrorTextHolder(snapshot.error);
          } else {
            return WaitingWidget();
          }
        },
      )
    );

  }

}