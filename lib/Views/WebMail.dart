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
    if (kIsWeb || Platform.isMacOS) {
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
        future: Future.wait([API.of(context).requests.getUsername(), API.of(context).requests.getMailJWTToken()]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String username = snapshot.data[0];
            String token = snapshot.data[1];
            // This is a dirty hack as WebView does not yet support
            // post data.
            // https://stackoverflow.com/a/67948632/8314475 is the source of this
            // code provided by Milad Ahmadi under CC BY-SA 4.0
            final String postParam= "{Email: '$username', Login: '$username', Password: '$token'}";
            final String loadWebmail="function post(path, params, method='post') {const form = document.createElement('form');form.method = method;form.action = path;for (const key in params) {if (params.hasOwnProperty(key)) {const hiddenField = document.createElement('input');hiddenField.type = 'hidden';hiddenField.name = key;hiddenField.value = params[key];form.appendChild(hiddenField);}}document.body.appendChild(form);form.submit();}post('https://webmail.kag-langenfeld.de/index.php?ExternalLogin', $postParam, method='post')";

            return WebView(
              onWebViewCreated: (controller) => controller.runJavascript(loadWebmail),
              javascriptMode: JavascriptMode.unrestricted,
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