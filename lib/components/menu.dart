import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Views/User.dart' as user_widget;
import '../api/api.dart';
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
          if (!kIsWeb && KAGAppState.app.type != AppType.LOGGED_OUT && API.of(context).requests.getUserInfo().isAppDev) PopupMenuItem(
            value: "fcmtoken",
            child: Text("Dev: FCM Token"),
          ),
          PopupMenuItem(
            value: "about",
            child: Text("Über die App"),
          ),
          if (KAGAppState.app.type != AppType.LOGGED_OUT)
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
  BottomNavigationBarMenu(this.type, this.controller);

  final TabController controller;
  final AppType type;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    switch (type) {
      case AppType.LOGGED_OUT:
        widgets = [
          Tab(
            text: "Home",
            icon: Icon(Icons.home, size: 35),
          ),
          Tab(
            text: "Termine",
            icon: Icon(Icons.event, size: 35),
          ),
          Tab(
            text: "News",
            icon: Icon(Icons.public, size: 35),
          ),
          Tab(
            text: "Login",
            icon: Icon(Icons.person, size: 35),
          )
        ];
        break;
      case AppType.NORMAL:
      case AppType.NORMAL_WITH_WEBMAIL:
        widgets = [
          Tab(
            text: "Home",
            icon: Icon(Icons.home, size: 35),
          ),
          Tab(
            text: "Termine",
            icon: Icon(Icons.event, size: 35),
          ),
          Tab(
            text: "News",
            icon: Icon(Icons.public, size: 35),
          ),
          Tab(
            text: "SPlan",
            icon: Icon(Icons.widgets, size: 35),
          ),
          Tab(
            text: "VPlan",
            icon: Icon(Icons.swap_horiz, size: 35),
          ),
          if (API.of(KAGAppState.app.context).requests.getUserInfo().homeworkConsent) Tab(
            text: "Hausaufgaben",
            icon: Icon(Icons.home_work_outlined, size: 35),
          ),
          if (type == AppType.NORMAL_WITH_WEBMAIL) Tab(
            text: "Mail",
            icon: Icon(Icons.mail, size: 35),
          ),
        ];
        break;
      case AppType.VPLAN_LOGGED_OUT:
        widgets = [
          Tab(
            text: "Login",
            icon: Icon(Icons.person, size: 35),
          ),
        ];
        break;
      case AppType.VPLAN:
        widgets = [
          Tab(
            text: "VPlan",
            icon: Icon(Icons.swap_horiz, size: 35),
          ),
          Tab(
            text: "SPlan",
            icon: Icon(Icons.widgets, size: 35),
          ),
        ];
        break;
      case AppType.MOBILE_SITE:
        widgets = [
          Tab(
            text: "News",
            icon: Icon(Icons.public, size: 35),
          ),
          Tab(
            text: "Termine",
            icon: Icon(Icons.event, size: 35),
          ),
          Tab(
            text: "Login",
            icon: Icon(Icons.person, size: 35),
          ),
        ];
        break;
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

// ignore: avoid_positional_boolean_parameters
List<NavigationRailDestination> getNavigationRail(AppType type) {
  switch (type) {
    case AppType.LOGGED_OUT:
      return <NavigationRailDestination>[
        NavigationRailDestination(
          label: Text("Home"),
          icon: Icon(Icons.home, size: 35),
        ),
        NavigationRailDestination(
          label: Text("Termine"),
          icon: Icon(Icons.event, size: 35),
        ),
        NavigationRailDestination(
          label: Text("News"),
          icon: Icon(Icons.public, size: 35),
        ),
        NavigationRailDestination(
          label: Text("Login"),
          icon: Icon(Icons.person, size: 35),
        )
      ];
    case AppType.NORMAL:
    case AppType.NORMAL_WITH_WEBMAIL:
      return <NavigationRailDestination>[
        NavigationRailDestination(
          label: Text("Home"),
          icon: Icon(Icons.home, size: 35),
        ),
        NavigationRailDestination(
          label: Text("Termine"),
          icon: Icon(Icons.event, size: 35),
        ),
        NavigationRailDestination(
          label: Text("News"),
          icon: Icon(Icons.public, size: 35),
        ),
        NavigationRailDestination(
          label: Text("SPlan"),
          icon: Icon(Icons.widgets, size: 35),
        ),
        NavigationRailDestination(
          label: Text("VPlan"),
          icon: Icon(Icons.swap_horiz, size: 35),
        ),
        NavigationRailDestination(
          label: Text("Hausaufgaben"),
          icon: Icon(Icons.home_work_outlined, size: 35),
        ),
        if (type == AppType.NORMAL_WITH_WEBMAIL) NavigationRailDestination(
          label: Text("Mail"),
          icon: Icon(Icons.mail, size: 35),
        ),
      ];
    case AppType.VPLAN_LOGGED_OUT:
      return <NavigationRailDestination>[
        NavigationRailDestination(
          label: Text("Login"),
          icon: Icon(Icons.person, size: 35),
        ),
        NavigationRailDestination( // We need this here as Flutter does not allow having only one item
          label: Text("Login"),
          icon: Icon(Icons.swap_horiz, size: 35),
        ),
      ];
    case AppType.VPLAN:
      return <NavigationRailDestination>[
        NavigationRailDestination(
          label: Text("VPlan"),
          icon: Icon(Icons.swap_horiz, size: 35),
        ),
        NavigationRailDestination(
          label: Text("SPlan"),
          icon: Icon(Icons.person, size: 35),
        ),
      ];
    case AppType.MOBILE_SITE:
      return <NavigationRailDestination>[
        NavigationRailDestination(
          label: Text("News"),
          icon: Icon(Icons.public, size: 35),
        ),
        NavigationRailDestination(
          label: Text("Termine"),
          icon: Icon(Icons.event, size: 35),
        ),
        NavigationRailDestination(
          label: Text("Login"),
          icon: Icon(Icons.person, size: 35),
        ),
      ];
  }
  return <NavigationRailDestination>[];
}