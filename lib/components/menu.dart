import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExtraOptionsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == "about") {
          showAboutDialog(
              context: context,
              applicationName: "KAG App",
              applicationVersion: "1.0",
              applicationLegalese: "Copyright KAG OnlineTeam 2019-2020\n\nThis App uses third-party software or other resources that may be distributed under different licenses. You can read them with the \"View Licenses\" button.",
              applicationIcon: Image.asset("assets/icon.png", width: 64,)
          );
        } else if (value == "support") {
          launch("mailto:app@kag-langenfeld.de");
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
            value: "about",
            child: Text("Über die App"),
          )
        ];
      },
    );
  }

}

class BottomNavigationBarMenu extends StatelessWidget {
  BottomNavigationBarMenu({this.isVPlanApp = false, this.controller});

  final bool isVPlanApp;
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(244, 244, 244, 1),
      child: TabBar(
        controller: controller,
        tabs: isVPlanApp ?
        // VPlan App
        <Widget>[
          Tab(
            text: "VPlan",
            icon: Icon(Icons.compare_arrows),
          ),
          Tab(
            text: "SPlan",
            icon: Icon(Icons.person),
          ),
        ] :
        // Normal App
        <Widget>[
          Tab(
            text: "Termine",
            icon: Icon(Icons.event),
          ),
          Tab(
            text: "VPlan",
            icon: Icon(Icons.compare_arrows),
          ),
          Tab(
            text: "Home",
            icon: Icon(Icons.home),
          ),
          Tab(
            text: "User",
            icon: Icon(Icons.person),
          ),
          Tab(
            text: "News",
            icon: Icon(Icons.public),
          ),
        ],
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