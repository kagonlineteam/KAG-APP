import 'dart:convert';

/// This file contains the models for the API
/// Evey model has a fromJSON Constructor which parses the JSON Map
/// To the model
/// This constructor can also be called like api_helpers.fromJSON<Termin>({"title": "test"});
/// When creating a new Model please also add it to api_helpers.formJSON (in api_helpers.dart)


class Termin {
  String _title, _id, _description, _preview;
  int _start, _stop;
  List<String> _tags;

  Termin(this._title, this._id, this._start, this._stop, this._description, this._tags);

  Termin.fromJSON(Map<dynamic, dynamic> rawJson) {
    if (rawJson.containsKey("id")) _id = rawJson['id'];
    if (rawJson.containsKey("title")) _title = rawJson['title'];
    if (rawJson.containsKey("start")) _start = rawJson['start'];
    if (rawJson.containsKey("stop")) _stop = rawJson['stop'];
    if (rawJson.containsKey("description") && rawJson['description'] != null && rawJson['description'].containsKey("body")) _description = utf8.decode(base64Decode(rawJson['description']['body']));
    if (rawJson.containsKey("description") && rawJson['description'] != null && rawJson['description'].containsKey("preview")) _preview = rawJson['description']['preview'];
    if (rawJson.containsKey("tags") && rawJson['tags'] != null && rawJson['tags'].length > 0) {
      for (var tag in rawJson['tags']) {
        if (tag != null && tag.containsKey('title') && tag['title'] != null) {
          _tags.add(tag['title']);
        }
      }
    }
  }

  int get stop => _stop;
  DateTime get stopDatetime => new DateTime.fromMillisecondsSinceEpoch(_stop * 1000);

  int get start => _start;
  DateTime get startDatetime => new DateTime.fromMillisecondsSinceEpoch(_start * 1000);

  String get id => _id;

  String get title => _title;

  List<String> get tags => _tags;

  String get description => _description;
  bool get hasDescription =>  _description != null;
  String get preview => _preview;
}

class VPlan {
  VPlan(this._id, this._date, this._lessons);

  // ignore: prefer_final_fields
  String _id;
  // ignore: prefer_final_fields
  DateTime _date;
  // ignore: prefer_final_fields
  String _file;
  // ignore: prefer_final_fields
  List<Lesson> _lessons;

  VPlan.fromJSON(Map<dynamic, dynamic> rawJson) {
    if (rawJson.containsKey("id")) _id = rawJson['id'];
    if (rawJson.containsKey("date")) _date = DateTime.fromMillisecondsSinceEpoch(int.parse(rawJson['date']) * 1000);
    if (rawJson.containsKey("files") && rawJson['files'].length > 0) _file = rawJson['files'][0]['id'];
    _lessons = [];
  }

  void addLesson(Lesson lesson) {
    _lessons.add(lesson);
  }

  String get id => _id;

  String get file => _file;

  DateTime get date => _date;

  List<Lesson> get lessons => _lessons;
}

class Lesson {
  Lesson(this._stunde, this._fach, this._klasse, this._raum, this._lehrer, this._type,
      this._v_fach, this._v_raum, this._v_klasse, this._v_lehrer);

  // ignore: non_constant_identifier_names
  String _stunde, _fach, _klasse, _raum, _lehrer, _type, _v_fach, _v_raum, _v_klasse, _v_lehrer, _infos;

  Lesson.fromJSON(Map<dynamic, dynamic> rawJson) {
    if (rawJson.containsKey("stunde")) _stunde = rawJson['stunde'];
    if (rawJson.containsKey("fach")) _fach = rawJson['fach'];
    if (rawJson.containsKey("klasse")) _klasse = rawJson['klasse'];
    if (rawJson.containsKey("raum")) _raum = rawJson['raum'];
    if (rawJson.containsKey("lehrer")) _lehrer = rawJson['lehrer'];
    if (rawJson.containsKey("art")) _type = rawJson['art'];
    if (rawJson.containsKey("v_fach")) _v_fach = rawJson['v_fach'];
    if (rawJson.containsKey("v_raum")) _v_raum = rawJson['v_raum'];
    if (rawJson.containsKey("v_klasse")) _v_klasse = rawJson['v_klasse'];
    if (rawJson.containsKey("v_lehrer")) _v_lehrer = rawJson['v_lehrer'];
    if (rawJson.containsKey("infos")) _infos = rawJson['infos'];
  }

  // ignore: non_constant_identifier_names
  String get v_lehrer => _v_lehrer;

  // ignore: non_constant_identifier_names
  String get v_klasse => _v_klasse;

  // ignore: non_constant_identifier_names
  String get v_raum => _v_raum;

  // ignore: non_constant_identifier_names
  String get v_fach => _v_fach;

  String get type => _type;

  String get lehrer => _lehrer;

  String get raum => _raum;

  String get klasse => _klasse;

  String get fach => _fach;

  String get infos => _infos;

  // ignore: unnecessary_getters_setters
  String get stunde => _stunde;

  // ignore: unnecessary_getters_setters
  set stunde(String value) {
    _stunde = value;
  }
}

class KAGUser {
  KAGUser(this._lastName, this._givenName, this._stufe, this._klasse, this._roles);

  KAGUser.fromJSON(Map<dynamic, dynamic> rawJSON) {
    if (rawJSON.containsKey("firstname")) _givenName = rawJSON['firstname'];
    if (rawJSON.containsKey("lastname")) _lastName = rawJSON['lastname'];
    if (rawJSON.containsKey("stufe")) _stufe = rawJSON['stufe'];
    if (rawJSON.containsKey("roles")) _roles = rawJSON['roles'].cast<String>();
  }

  String _givenName, _lastName, _stufe, _klasse;
  List<String> _roles;

  String get appropriateName {
    if (_roles.contains("ROLE_LEHRER")) {
      return _lastName;
    }
    return _givenName;
  }

  List<String> get roles => _roles;

  // ignore: unnecessary_getters_setters
  String get klasse => _klasse;

  String get stufe => _stufe;

  String get name => _lastName;

  String get givenName => _givenName;

  // ignore: unnecessary_getters_setters
  set klasse(String value) {
    _klasse = value;
  }
}

class Article {
  String _title, _id, _htmlBody;
  Map<String, String> _image;

  Article(this._id, this._title, this._htmlBody, this._image);

  Article.fromJSON(Map<dynamic, dynamic> rawJSON) {
    if (rawJSON.containsKey("id")) _id = rawJSON['id'];
    if (rawJSON.containsKey("title")) _title = rawJSON['title'];
    if (rawJSON.containsKey("body")) _htmlBody = utf8.decode(base64Decode(rawJSON['body'].replaceAll('\n', '')));
    if (rawJSON.containsKey("files") && rawJSON['files'] is Map) _image = new Map<String, String>.from(rawJSON['files']);
  }

  // Image stuff
  String get imageID => _image != null ? _image['id'] : null;
  bool get hasImage => _image != null;

  String get title => _title;
  String get id => _id;
  String get htmlBody => _htmlBody;
}

///
/// This model is only used in UnitTests, as it only saves data
///
class MockModel {
  final Map<dynamic, dynamic> rawJSON;
  MockModel.fromJSON(this.rawJSON);
}