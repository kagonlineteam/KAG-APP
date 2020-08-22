import 'dart:convert';

class Termin {
  String _title, _id, _description;
  int _start, _stop;
  List<String> _tags;

  Termin(this._title, this._id, this._start, this._stop, this._description, this._tags);

  Termin.fromJSON(Map<dynamic, dynamic> rawJson) {
    if (rawJson.containsKey("id")) _id = rawJson['id'];
    if (rawJson.containsKey("title")) _title = rawJson['title'];
    if (rawJson.containsKey("start")) _start = rawJson['start'];
    if (rawJson.containsKey("stop")) _stop = rawJson['stop'];
    if (rawJson.containsKey("description") && rawJson['description'] != null && rawJson['description'].containsKey("body")) _description = utf8.decode(base64Decode(rawJson['description']['body']));
    if (rawJson.containsKey("tags") && rawJson['tags'] != null && rawJson['tags'].length > 0) {
      for (var tag in rawJson['tags']) {
        if (tag != null && tag.containsKey('title') && tag['title'] != null) {
          _tags.add(tag['title']);
        }
      }
    }
  }

  int get stop => _stop;

  int get start => _start;

  String get id => _id;

  String get title => _title;

  List<String> get tags => _tags;

  String get description => _description;
}