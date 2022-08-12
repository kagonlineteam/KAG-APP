import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Views/User.dart' as user_widget;
import '../api/api.dart';
import '../app_type/app_type_managment.dart';
import '../app_type/pages.dart';
import '../main.dart';
import '../push_notifications.dart';
import 'dev.dart';

class ExtraOptionsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == "about") {
          if (!kIsWeb) {
            PackageInfo.fromPlatform().then((packageInfo) {
              showAboutDialog(
                  context: context,
                  applicationName: "KAG App ${packageInfo.appName}",
                  applicationVersion: "${packageInfo.version} VC${packageInfo.buildNumber}",
                  applicationLegalese: "Copyright KAG OnlineTeam 2019-2022\nDie App ist unter der GNU GPLv3 lizensiert und der Source Code verfügbar.\n\nThis App uses third-party software or other resources that may be distributed under different licenses. You can read them with the \"View Licenses\" button.",
                  applicationIcon: Image.asset("assets/icon.png", width: 64,)
              );
            });
          } else {
            showAboutDialog(
                context: context,
                applicationName: "KAG App Web",
                applicationLegalese: "Copyright KAG OnlineTeam 2019-2022\nDie App ist unter der GNU GPLv3 lizensiert und der Source Code verfügbar.\n\nThis App uses third-party software or other resources that may be distributed under different licenses. You can read them with the \"View Licenses\" button.",
                applicationIcon: Image.asset("assets/icon.png", width: 64,)
            );
          }

        } else if (value == "support") {
          launchUrl(Uri.parse("mailto:app@kag-langenfeld.de"));
        } else if (value == "kagsupport") {
          launchUrl(Uri.parse("mailto:support@kag-langenfeld.de"));
        } else if (value == "source") {
          launchUrl(Uri.https("github.com", "kagonlineteam/KAG-APP"));
        } else if (value == "logout") {
          user_widget.User.logout(context);
        } else if (value == "fcmtoken") {
          SharedPreferences.getInstance().then((sp) => showData(context, sp.getString(PushNotificationsManager.SP_FIREBASE_TOKEN)));
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: "support",
            child: Text("Fehler melden"),
          ),
          PopupMenuItem(
            value: "support",
            child: Text("Feature anfragen"),
          ),
          PopupMenuItem(
            value: "kagsupport",
            child: Text("KAG Account support"),
          ),
          PopupMenuItem(
            value: "source",
            child: Text("Source Code der App"),
          ),
          if (!kIsWeb && KAGAppState.app.appType != AppType.LOGGED_OUT && API.of(context).requests.getUserInfo().isAppDev) PopupMenuItem(
            value: "fcmtoken",
            child: Text("Dev: FCM Token"),
          ),
          PopupMenuItem(
            value: "about",
            child: Text("Über die App"),
          ),
          if (KAGAppState.app.appType != AppType.LOGGED_OUT)
            PopupMenuItem(
              value: "logout",
              child: Text("Ausloggen")
            )
        ];
      },
    );
  }

}

class BottomNavigationBarMenu extends StatelessWidget {
  BottomNavigationBarMenu(this.pages, this.controller);

  final TabController controller;
  final List<AppPage> pages;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (AppPage page in pages) {
      widgets.add(Tab(
        text: getPageName(page),
        icon: Icon(getPageIcon(page), size: 35),
      ));
    }

    return Container(
      color: Color.fromRGBO(244, 244, 244, 1),
      child: TabBar(
        controller: controller,
        tabs: widgets,
        isScrollable: false,
        labelColor: Color.fromRGBO(47, 109, 29, 1),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.transparent,
        labelStyle: TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }
}

List<NavigationRailDestination> getNavigationRail(List<AppPage> pages) {
  List<NavigationRailDestination> navRail = [];
  for (AppPage page in pages) {
    navRail.add(NavigationRailDestination(
      label: Text(getPageName(page)),
      icon: Icon(getPageIcon(page), size: 35),
    ));
  }
  return navRail;
}