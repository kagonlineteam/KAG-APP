import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../api/api.dart';
import '../api/api_models.dart';
import '../components/helpers.dart';
import '../components/terminlist.dart';

// This class is used as a way to convince
// flutter to only re-build this widget and not _Calendar
// which would cause a issue with double subscribing to
// a stream
// TODO this should probably be removed and a better
// solution found
class Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Calendar();
  }

}

// This Widget is used to switch between ListView and TableView
class _Calendar extends StatelessWidget {

  static const String SP_LOAD_TERMIN_LIST = "load_termine_as_list";

  final StreamController controller;

  _Calendar():
      controller = new StreamController() {
    SharedPreferences.getInstance().then((sp) => controller.add(sp.containsKey(SP_LOAD_TERMIN_LIST)? sp.getBool(SP_LOAD_TERMIN_LIST) : false));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                  title: Align(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Termine"),
                        RaisedButton(
                            onPressed: () => _switchView(!snapshot.data),
                            child: Container(
                              child: Text(snapshot.data ? "Als Kalender" : "Als Liste",
                                  style: TextStyle(fontSize: 15, color: Colors.white)),
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerRight,
                            )
                        ),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                  )),
              body: snapshot.data ? _ListCalendar() : _TableCalendar());
        } else {
          return WaitingWidget();
        }
      },
    );
  }

  void _switchView(bool showList) {
    SharedPreferences.getInstance().then((sp) => sp.setBool(SP_LOAD_TERMIN_LIST, showList));
    controller.add(showList);
  }

}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class _ListCalendar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ResourceListBuilder(
      API.of(context).requests.getFutureCalendarEntries,
          (data, controller) =>
          ListView(
            itemExtent: 120,
            controller: controller,
            children: data.map((termin) => TerminWidget(termin)).toList(),
          ),
    );
  }
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class CalendarDetail extends StatelessWidget {
  CalendarDetail(this.originalTermin);

  final Termin originalTermin;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: API.of(context).requests.getTermin(originalTermin.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CalendarDetailWidget(snapshot.data);
        } else if (!snapshot.hasError) {
          return Stack(
            children: [
              CalendarDetailWidget(originalTermin),
              Center(child: CircularProgressIndicator())
            ],
          );
        } else {
          return CalendarDetailWidget(originalTermin);
        }
      },
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
    List<Termin> termine = await API.of(context).requests.getCalendarForMonth(month, year);
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
      availableGestures: AvailableGestures.horizontalSwipe,                                       //----------
      initialCalendarFormat: CalendarFormat.month,
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
        formatButtonVisible: false,                                                               //----------
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