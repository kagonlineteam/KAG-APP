import 'package:flutter/material.dart';
import '../api/api.dart';
import '../app_type/app_type_managment.dart';
import '../main.dart';

class KrankmeldungWidget extends StatefulWidget {
  State<KrankmeldungWidget> createState() => new KrankmeldungState();
}

class KrankmeldungState extends State<KrankmeldungWidget> {

  String sek, name, grade, klasse, leader, email, remarks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Krankmeldung erstellen")
        ),
        body: Container(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                  children: [
                    DropdownButton<String>(
                        value: sek,
                        onChanged: (newSek) {
                          setState(() {
                            sek = newSek;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            child: Text('Sekundarstufe'),
                            value: null,
                          ),
                          DropdownMenuItem(
                            child: Text('I (5. - 9. Klasse)'),
                            value: 'sek1',
                          ),
                          DropdownMenuItem(
                            child: Text('II (EF - Q2)'),
                            value: 'sek2',
                          )
                        ]
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: "Name"),
                        maxLines: 1,
                        initialValue: '',
                        onChanged: (value) {
                          name = value;
                        }
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: sek == 'sek2' ? 'Stufe' : 'Klasse'),
                        maxLines: 1,
                        initialValue: '',
                        onChanged: (value) {
                          if (sek == 'sek2') {
                            grade = value;
                          } else {
                            klasse = value;
                          }
                        }
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: sek == 'sek2' ? 'Stufenleitung' : 'Klassenleitung'),
                        maxLines: 1,
                        initialValue: '',
                        onChanged: (value) {
                          leader = value;
                        }
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: 'E-Mail-Adresse'),
                        maxLines: 1,
                        initialValue: '',
                        onChanged: (value) {
                          email = value;
                        }
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Bemerkungen'),
                        maxLines: 2,
                        initialValue: '',
                        onChanged: (value) {
                          remarks = value;
                        }
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 0, top: 50, right: 0, bottom: 60),
                        child: ElevatedButton(
                            child: Text('Krankmeldung absenden', style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              await API.of(context).requests.sendKrankmeldung(sek, name, grade, klasse, leader, email, remarks);
                              KAGAppState().goToPage(AppPage.CALENDAR);
                            }
                        )
                    )
                  ]
              )
            )
        )
    );
  }
}