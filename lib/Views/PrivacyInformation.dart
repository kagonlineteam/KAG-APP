import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import './News.dart';
import '../api/api.dart';
import '../api/api_models.dart';

class PrivacyInformation extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: TabBar(
                tabs: [
                  Tab(text: 'Datenschutz'),
                  Tab(text: 'Impressum',)
                ],
              ),
            ),
            body: TabBarView(
              children: [
                FutureBuilder(
                  future: API.of(context).requests.getArticle('Y7XsWhFGGgeITfmmEAjo7'),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return TabBarPage(snapshot.data);
                    } else {
                      return Center(
                        child: Text('Die Datenschutzerklärung konnte nicht geladen werden. Bitte überprüfen sie ihre Internetverbindung'),
                      );
                    }
                  },
                ),
                FutureBuilder(
                  future: API.of(context).requests.getArticle('mz8Ohncn3OiFJPRfhwsGr'),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return TabBarPage(snapshot.data);
                    } else {
                      return Center(
                        child: Text('Das Impressum konnte nicht geladen werden. Bitte überprüfen sie ihre Internetverbindung'),
                      );
                    }
                  },
                )
              ],
            )
        )
    );
  }
}

class TabBarPage extends StatelessWidget {
  TabBarPage(this.content);

  final Article content;

  @override
  Widget build(BuildContext context) {
    var htmlData = """${content.htmlBody != null ? content.htmlBody : ""}""";
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[Html(data: htmlData, onLinkTap: _launch)],
        ),
        padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
      ),
    );
  }

  static void _launch(String url) {
    launchUrl(Uri.parse(url));
  }

}