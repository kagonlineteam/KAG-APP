import 'package:flutter/material.dart';
import '../api/api.dart';
import '../app_type/app_type_managment.dart';
import '../main.dart';

class KrankmeldungWidget extends StatefulWidget {
  State<KrankmeldungWidget> createState() => new KrankmeldungState();
}

class KrankmeldungState extends State<KrankmeldungWidget> {

  String sek = '', name = '', grade = '', leader = '', email = '', remarks = '', info = '';
  bool checked = false;

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
                            child: Text('Sekundarstufe *'),
                            value: '',
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
                        decoration: InputDecoration(labelText: "Name *"),
                        maxLines: 1,
                        initialValue: '',
                        onChanged: (value) {
                          name = value;
                        }
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: sek == 'sek2' ? 'Stufe*' : 'Klasse *'),
                        maxLines: 1,
                        initialValue: '',
                        onChanged: (value) {
                          grade = value;
                        }
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: sek == 'sek2' ? 'Stufenleitung *' : 'Klassenleitung *'),
                        maxLines: 1,
                        initialValue: '',
                        onChanged: (value) {
                          leader = value;
                        }
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: 'E-Mail-Adresse *'),
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
                        padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
                        child: CheckboxListTile(
                          title: Text("Ich habe den Datenschutzhinweis zur Kenntnis genommen und willige in die Verarbeitung der von mir angegebenen Daten ein. *", style: TextStyle(fontSize: 15)),
                          value: checked,
                          onChanged: (value) {
                            setState(() {
                              checked = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        )
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
                      child: Text("Alle Felder mit einem * sind Pflichtfelder")
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
                        child: Text(info)
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 0, top: 30, right: 0, bottom: 60),
                        child: ElevatedButton(
                            child: Text('Krankmeldung absenden', style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              if ( (sek == 'sek1' || sek == "sek2") && (grade != '' && name != '' && leader != '' && email != '' && checked) ) {
                                var response = await API.of(context).requests.sendKrankmeldung(sek, name, grade, leader, email, remarks);
                                if (response == false) {
                                  setState(() {
                                    info = 'Es ist ein Fehler aufgetreten';
                                  });
                                } else {
                                  KAGAppState.app.goToPage(AppPage.CALENDAR);
                                }
                              } else {
                                setState(() {
                                  info = 'Es wurden nicht alle Pflichtfelder ausgefüllt!';
                                });
                              }
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