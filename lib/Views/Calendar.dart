import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_models.dart';
import '../main.dart';


class Calendar extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  bool showList = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            child: Text("Termine",
                style: TextStyle(fontSize: 30)),
            alignment: Alignment.centerLeft,
          ),
           RaisedButton(
              onPressed: _switchView,
              child: Container(
                child: Text(showList ? "Als Kalender" : "Als Liste",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                alignment: Alignment.centerRight,
              )
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    )),
    body: showList ? _ListCalendar() : _TableCalendar(),);
  }

  void _switchView() {
    setState(() {
      showList = !showList;
    });
  }

}

class _ListCalendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListCalendarState();
  }
}

class _ListCalendarState extends State {
  static const dateStyle = const TextStyle(fontSize: 20, color: Colors.white);
  static const titleStyle = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 1);
  static const descriptionStyle = const TextStyle(fontSize: 15);
  int page = 0;
  List<Widget> rows = <Widget>[];
  ScrollController controller = ScrollController();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: GestureDetector(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: ListView(
                controller: controller,
                children: rows,
              ),
            )
        )
    );
  }

  Future<Widget> _generateRow(entry) async {
    var descriptionText = entry['description'] != null ? entry['description']['preview'] : "";
    var dateOne     = new DateTime.fromMillisecondsSinceEpoch(entry['start'] * 1000);
    var dateTwo     = new DateTime.fromMillisecondsSinceEpoch(entry['stop'] * 1000);
    var dateOneText = "${betterNumbers(dateOne.day)}.${betterNumbers(dateOne.month)}.";
    var dateTwoText = "${betterNumbers(dateTwo.day)}.${betterNumbers(dateTwo.month)}.";

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(172, 172, 172, 1), width: 2))),
      child: GestureDetector(
        child: Row(
          children: <Widget>[
              Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 30, 10),
                  width: 80,
                  height: 85,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: generateDateWidget(dateOneText, dateTwoText),
                  )
              ),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(entry['title'], style: titleStyle),
                      alignment: Alignment.topLeft,
                    ),
                    Container(
                      child: Text(getShortedLongDescription(descriptionText),
                          style: descriptionStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                      alignment: Alignment.topLeft,
                      height: 50,
                    )
                  ],
                ),
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => CalendarDetail(new Termin.fromJSON(entry)))),
      ),
    );
  }

  Widget generateDateWidget(String dateOneText, String dateTwoText) {
    if (dateOneText == dateTwoText) {
      return Container(
        color: Color.fromRGBO(47, 109, 29, 1),
        child: Center(
          child: Container(
            child: Text(dateOneText, style: dateStyle),
          ),
        ),
        width: 100,
        height: 50,
      );
    }
    return Container(
      color: Color.fromRGBO(47, 109, 29, 1),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(dateOneText, style: dateStyle),
          ),
          Container(
            child: Image.asset("assets/arrow.png"),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(dateTwoText, style: dateStyle),
          )
        ],
      ),
      width: 100,
      height: 100,
    );
  }

  Future loadEntries() async {
    final entries = await KAGApp.api.requests.getCalendarEntriesSoon(page);
    if (entries != null) {
      var entryRows = List<Widget>.from(rows);
      for (var entry in entries) {
          entryRows.add(await _generateRow(entry));
      }
      setState(() {
        rows = entryRows;
      }
      );
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.atEdge) {
        if (controller.position.pixels != 0) {
            page++;
            loadEntries();
          }
    }
    });
    loadEntries();
  }

  String getShortedLongDescription(String text) {
    if (text == null) return "";
    if (text.length > 300) {
      return "${text.substring(0, 300)}...";
    } else {
      return text;
    }
  }

  String betterNumbers(int originalNumber) {
    if (originalNumber < 10) {
      return "0$originalNumber";
    }
    return "$originalNumber";
  }
}

class CalendarDetail extends StatefulWidget {
  CalendarDetail(final this.entry);
  final Termin entry;

  @override
  State<StatefulWidget> createState() {
    return new CalendarDetailState(entry);
  }

}

class CalendarDetailState extends State {
  CalendarDetailState(this.entry);

  Termin entry;
  static const dateStyle        = const TextStyle(fontSize: 25, color: Colors.white);
  static const titleStyle       = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 1);
  static const tagStyle         = const TextStyle(fontSize: 16, color: Colors.white);
  static const timeStyle        = const TextStyle(fontSize: 16, color: Colors.white);

  @override
  void initState() {
    super.initState();
    loadTerminInfos();
  }

  String betterNumbers(int originalNumber) {
    if (originalNumber < 10) {
      return "0$originalNumber";
    }
    return "$originalNumber";
  }

  void loadTerminInfos() async {
    var entry = await KAGApp.api.requests.getCalenderEntryById(this.entry.id);
    setState(() {
      this.entry = entry;
    });
  }

  // Build design

  @override
  Widget build(BuildContext context) {
    var title = entry.title;

    DateTime dateObjectOne = DateTime.fromMillisecondsSinceEpoch(entry.start * 1000);
    DateTime dateObjectTwo = DateTime.fromMillisecondsSinceEpoch(
        entry.stop * 1000);

    // Support both. One less second and one less millisecond
    bool allDay = dateObjectTwo.difference(dateObjectOne).inMilliseconds == (1000 * 60 * 60 * 24) - 1 || dateObjectTwo.difference(dateObjectOne).inMilliseconds == (1000 * 60 * 60 * 24) - 1000;

    var dateOne = "${betterNumbers(dateObjectOne.day)}.${betterNumbers(
        dateObjectOne.month)}.";
    var dateTwo = "${betterNumbers(dateObjectTwo.day)}.${betterNumbers(
        dateObjectTwo.month)}.";
    var timeOne = "${betterNumbers(dateObjectOne.hour)}:${betterNumbers(dateObjectOne.minute)} Uhr";
    var timeTwo = "${betterNumbers(dateObjectTwo.hour)}:${betterNumbers(dateObjectTwo.minute)} Uhr";

    Widget description = Text("");
    if (entry.description != null) {
      description = Html(data: entry.description.replaceAll('\n', ''), onLinkTap: launch);
    }

    List<Widget> tags = [];

    if (entry.tags != null) {
      for (String tagString in entry.tags) {
        tags.add(createTag(tagString));
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Container(
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        title,
                        style: titleStyle,
                      ),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      alignment: Alignment.centerLeft,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  dateOne,
                                  style: dateStyle,
                                ),
                                !allDay ? Text(
                                  timeOne,
                                  style: timeStyle,
                                ) : Container()
                              ],
                            ),
                            margin: EdgeInsets.fromLTRB(20, 10, 0, 10),
                          ),
                          Container(
                            child: Image.asset("assets/arrow_horizontal.png"),
                          ),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  dateTwo,
                                  style: dateStyle,
                                ),
                                !allDay ? Text(
                                  timeTwo,
                                  style: timeStyle,
                                ) : Container()
                              ],
                            ),
                            margin: EdgeInsets.fromLTRB(0, 10, 20, 10),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      height: 70,
                      color: Color.fromRGBO(47, 109, 29, 1),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                    /*Container(
                  child: Row(
                    children: tags,
                  ),
                  margin: EdgeInsets.fromLTRB(10, 10, 20, 10),
                ),*/
                    Container(
                      child: description,
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      alignment: Alignment.topLeft,
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }



  Widget createTag(String title) {
    return Container(
      child: Container(
        child: Text(
          title,
          style: tagStyle,
        ),
        margin: EdgeInsets.fromLTRB(10, 2, 10, 2),
      ),
      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      decoration: BoxDecoration(
          color: Color.fromRGBO(47, 109, 29, 1),
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
  }
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class _TableCalendar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _TableCalendarState();
  }
}

class _TableCalendarState extends State<_TableCalendar> with TickerProviderStateMixin{

  Map<DateTime, List> _events;
  List<String> _loadedMonths;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;

  void fillCalendar(int month, int year) async {
    _loadedMonths.add(month.toString() + year.toString());
    List<Termin> termine = await KAGApp.api.requests.getCalendarForMonth(month, year);
    for (var termin in termine) {
      var terminDate = DateTime.fromMillisecondsSinceEpoch(termin.start*1000);
      var date = new DateTime(terminDate.year, terminDate.month, terminDate.day);
      if (_events[date] == null) {
        setState(() {
          _events[date] = [termin];
        });
      } else {
        _events[date].add(termin);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final currentYear  = DateTime.now().year;
    final currentMonth = DateTime.now().month;
    final _selectedDay = DateTime.now();


    _loadedMonths = [];
    _events = {};
    _selectedEvents = _events[_selectedDay] ?? [];
    fillCalendar(currentMonth, currentYear);

    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
      if (_selectedEvents.length == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CalendarDetail(_selectedEvents[0])));
      } else if (_selectedEvents.length > 1) {
        _showEventListModal();
      }
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) async {
    if (!_loadedMonths.contains(first.month.toString() + first.year.toString())) {
      await fillCalendar(first.month, first.year);
    }
    // We do assume here that a maximum of two month can be shown at the same time
    // If this proves itself to be wrong we have to change that
    if (!_loadedMonths.contains(last.month.toString() + last.year.toString())) {
      await fillCalendar(last.month, last.year);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildTableCalendar(),
        ],
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'de_DE',
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.monday,
      builders: CalendarBuilders(
        todayDayBuilder: (context, date, list) {
          return _buildDay(date, list, today: true);
        },
        dayBuilder: (context, date, list) {
          return _buildDay(date, list);
        },
        markersBuilder: (context, date, hlist, dlist) {
          return [new Container(), new Container()];
        },
      ),
      rowHeight: (MediaQuery.of(context).size.height - 150) / 7,
      calendarStyle: CalendarStyle(
        selectedColor: Color.fromRGBO(255, 145, 10, 1),
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Color.fromRGBO(255, 145, 10, 1),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),

      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildDay(date, events, {today=false}) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.only(top: 5.0, left: 6.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3.0),
            decoration: today ? new BoxDecoration(borderRadius: new BorderRadius.circular(16.0), color: Theme.of(context).accentColor) : null,
            child:
          Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0)),
          ),
          _buildEventsList(events)
        ],
      ),
    );
  }

  // Builds the list before a day has been selected
  Widget _buildEventsList(List events) {
    if (events == null) return Text("");
    List<Widget> eventWidgets = [];
    for (var event in events) {
      eventWidgets.add(Text(event.title, style: TextStyle().copyWith(fontSize: MediaQuery.of(context).size.longestSide > 1000 ? 13 : 7),));
    }
    return Column(
      children: eventWidgets,
    );
  }


  // Builds the list shown after a day has been selected
  void _showEventListModal() {
    showDialog(context: context, builder: (context) {
      return CupertinoAlertDialog(
        title: Text("Es gibt mehrere Termine"),
        content: Column(
          children: _selectedEvents
              .map((event) => Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.8),
              borderRadius: BorderRadius.circular(12.0),
              color: Theme.of(context).buttonColor
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: MaterialButton(
              child: Text(event.title, style: TextStyle(color: Colors.white),),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CalendarDetail(event))),
            ),
          ))
              .toList(),
        )
      );
    });
  }
}