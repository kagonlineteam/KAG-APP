import 'package:flutter/material.dart';

import '../api/api.dart';
import '../components/helpers.dart';
import '../components/home.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurroundingWidget(
      child: FutureBuilder(
        future: API.of(context).requests.getHomescreen(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Image.asset("assets/eule-rund.png");
          } else if (!snapshot.hasData) {
            return WaitingWidget();
          } else {
            return HomeList(snapshot.data);
          }
        },
      )
    );
  }

}
