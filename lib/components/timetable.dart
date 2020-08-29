import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TimeTable extends StatelessWidget {
  TimeTable(this.plan);

  final String plan;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launch(
          "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$plan.pdf"),
      onScaleStart: (details) => launch(
          "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$plan.pdf"),
      child: OrientationBuilder(builder: (context, orientation) {
        return Image.network(
          "https://kag-langenfeld.de/sites/default/files/files//schueler/sek_I/stundenpl%C3%A4ne/Stundenplan%20$plan.pdf.png",
          //height: MediaQuery.of(context).size.height - 100,
        );
      }),
    );
  }

}