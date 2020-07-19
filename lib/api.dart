import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as foundation;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

enum APIAction {
  GET_USERNAME,
  GET_GROUPS,
  GET_CALENDAR,
  GET_RPLAN_TODAY,
  GET_RPLAN_TOMORROW,
  GET_RPLAN_DAYAFTERTOMMOROW,
  GET_USER_INFO,
  GET_ARTICLE

}

class API {
  _User _user;

  API() {
    _user = _User();
  }

  ///
  /// Returns if endpoint needs Login
  /// Hardcoded to save data
  ///
  bool _isLogInNeeded(APIAction action) {
    switch (action) {
      case APIAction.GET_USERNAME:
        return true;
      case APIAction.GET_GROUPS:
        return true;
      case APIAction.GET_CALENDAR:
        return false;
      case APIAction.GET_RPLAN_TODAY:
        return true;
      case APIAction.GET_RPLAN_TOMORROW:
        return true;
      case APIAction.GET_RPLAN_DAYAFTERTOMMOROW:
        return true;
      case APIAction.GET_USER_INFO:
        return true;
      case APIAction.GET_ARTICLE:
        return false;
    }
    return true;
  }

  ///
  /// Returns if login credentials are saved
  /// This does not check its validity
  ///
  Future<bool> hasLoginCredentials() async {
    return await _user._hasLoginCredentialsSaved();
  }

  ///
  /// calls _isLogInNeeded to check if logIn is needed -> Logs in
  /// Returns APIRequest to user to allow executing method there.
  ///
  Future<_APIRequest> getAPIRequest(APIAction action) async {
    if (_isLogInNeeded(action) && !_user.isLoggedIn()) {
      if (!await _user.login()) {
        return null;
      }
    }
    return new _APIRequest(action, _user);
  }


  ///
  /// Return a new API Instace for Sync Tasks
  /// This only works for not login requiring tasks and GET_GROUPS and GET_USERNAME
  /// WARNING: This is not recommend for GET_GROUPS and GET_USERNAME only if you absolutely need it
  ///
  _APIRequest getAPIRequestSync(APIAction action) {
    if (_isLogInNeeded(action) && action != APIAction.GET_GROUPS && action != APIAction.GET_USERNAME) throw Exception("Can not load a login needing Task synchronously");
    return new _APIRequest(action, _user);
  }

  ///
  /// Calls setLoginCredentials in User
  ///
  Future<bool> setLoginCredentials(String username, String password) async {
    return await _user.setLoginCredentials(username, password);
  }
}

class _User {
  String _jwt;
  String _refreshJWT;
  // The boolean does indicate if a login process is currently happening
  // This prevents erros with using a refresh token twice. See _User.login()
  bool _loggingIn = false;

  ///
  /// Checks if user is loggedin
  /// Does check if log in is valid, too
  ///
  bool isLoggedIn() {
    if (_jwt != null &&
        getDecodedJWT()['exp'] >
            (new DateTime.now().millisecondsSinceEpoch / 1000)) {
      return true;
    }
    return false;
  }

  ///
  /// Saves username and password
  /// Changed: Now it does login to gain a refresh token
  ///
  Future<bool> setLoginCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    if (password == null) {
      prefs.remove("refresh");
      prefs.remove("username");
      prefs.remove("token");
      return false;
    }
    var obj = await _APIConnection.login(
        prefs.getString("username"), password);
    if (obj == null) return false;
    _jwt = obj["token"];
    _refreshJWT = obj["refresh"];
    prefs.setString("token", _jwt);
    prefs.setString("refresh", _refreshJWT);
    return true;
  }

  ///
  /// Login to API
  /// Gets jwt and saves it to variable
  /// Loads username/password from save if needed
  ///
  /// Returns if login successful
  ///
  Future<bool> login() async {
    if (_loggingIn) {
      // If already logging in wait till this is over and just return if that succeeded
      // This may not be the cleanest way to implement that but because it is
      // asynchronous this should be OK
      await Future.doWhile(() => _loggingIn);
      return isLoggedIn();
    }
    _loggingIn = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if the saved JWT is still valid if none is cached (This has to be done because a new jwt can not be issued before the old one is expired)
    if (_jwt == null) {
      _jwt = await prefs.getString("token");
      if (isLoggedIn()) return true;
    }
    // Load Refresh from disk if not cached
    if (_refreshJWT == null) {
      _refreshJWT = prefs.getString("refresh");
      // We don't even need to try to login without refresh
      if (_refreshJWT == null) return false;
    }
    var obj = await _APIConnection.refreshLogin(
        prefs.getString("username"), _refreshJWT);
    if (obj == null) return false;
    _jwt = obj["token"];
    _refreshJWT = obj["refresh"];
    prefs.setString("token", _jwt);
    prefs.setString("refresh", _refreshJWT);
    _loggingIn = false;
    return true;
  }

  ///
  /// Returns groups of user.
  /// Null if not logged in.
  ///
  List<dynamic> getGroups() {
    return getDecodedJWT()['roles'];
  }

  ///
  /// Read Username from jwt if exists
  ///
  String getUsername() {
    return getDecodedJWT()['user'];
  }

  ///
  /// Returns jwt if exists
  ///
  String getJWT() {
    return _jwt;
  }

  // ignore: type_annotate_public_apis
  getDecodedJWT() {
    String output =
    _jwt.split(".")[1].replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }
    return jsonDecode(utf8.decode(base64Url.decode(output)));
  }

  ///
  /// Returns if login credentials are saved
  /// This does not check its validity
  ///
  Future<bool> _hasLoginCredentialsSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("token");
  }
}

class _APIConnection {
  static const API = "https://apiv2.kag-langenfeld.de/";

  ///
  /// Makes Login request.
  /// Returns an Object with token and refresh token
  ///
  static Future<Map<String, String>> login(String username,
      String password) async {
    var loginBody = jsonEncode(
        {"username": username, "password": password, "client": "appclient"});
    var response = await http.post("${API}login?type=refresh", body: loginBody,
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      return {"token": res['access_token'], "refresh": res['refresh_token']};
    }
    return null;
  }

  ///
  /// Makes Refresh Login request.
  /// Returns an Object with token and refresh token
  ///
  static Future<Map<String, String>> refreshLogin(String username,
      String refreshToken) async {
    var loginBody = jsonEncode(
        {"username": username, "refresh_token": refreshToken, "client": "appclient"});
    var response = await http.post("${API}refresh?type=refresh", body: loginBody,
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      return {"token": res['access_token'], "refresh": res['refresh_token']};
    }
    return null;
  }

  ///
  /// GET from API
  /// Makes request, returns response body
  /// If not successful returns null
  /// Will not send authorization header if jwt is null
  ///
  static Future<String> getFromAPI(String path, Map<String, String> params,
      String jwt) async {
    String query = "";
    if (params != null) {
      query = "?";
      params.forEach((name, value) {
        if (query != "?") query += "&";
        query += "$name=$value";
      });
    }
    KAGApp.app.setLoading();
    var request =  (await http.get("$API$path$query",
        headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null))
        .body;
    KAGApp.app.setLoading(loading: false);
    return request;
  }
}

class _APIRequest {
  APIAction _endpoint;
  _User _user;
  _CacheManager _cache;

  ///
  /// Handles Request, checks parameter etc.
  /// Login status should be already checked.
  /// Throws exception if different method is executed than specified as Action
  ///
  _APIRequest(APIAction endpoint, _User user) {
    _endpoint = endpoint;
    _user = user;
    _cache = _CacheManager(endpoint);
  }

  ///
  /// Return action of request
  ///
  APIAction getAction() {
    return _endpoint;
  }

  ///
  /// Check if action is specified action else throw exception
  ///
  void _actionExecution(APIAction action) {
    if (!(_endpoint == action ||
        (_endpoint == APIAction.GET_RPLAN_TOMORROW &&
            action == APIAction.GET_RPLAN_TODAY) ||
        (_endpoint == APIAction.GET_RPLAN_DAYAFTERTOMMOROW &&
            action == APIAction.GET_RPLAN_TODAY))) {
      throw Exception("Not configured Action called.");
    }
  }

  ///
  /// Returns username
  ///
  String getUsername() {
    _actionExecution(APIAction.GET_USERNAME);
    return _user.getUsername();
  }

  ///
  /// Returns users groups
  ///
  List<dynamic> getGroups() {
    _actionExecution(APIAction.GET_GROUPS);
    return _user.getGroups();
  }

  ///
  /// Returns Termin entries for Month
  ///
  Future<List<Termin>> getCalendarForMonth(int month, int year) async {
    _actionExecution(APIAction.GET_CALENDAR);
    int start = (new DateTime(year, month, 1).millisecondsSinceEpoch ~/ 1000);
    int end = (new DateTime(year, month + 1, 1).millisecondsSinceEpoch ~/ 1000);
    String response = await _APIConnection.getFromAPI(
        "termine",
        {"start": "gte-$start", "stop": "lte-$end", "view": "runtime", "limit": "100"},
        _user.isLoggedIn() ? _user.getJWT() : null);
    var jsonResponse = json.decode(response)['entities'];
    List<Termin> entries = [];
    for (var entity in jsonResponse) {
      entries.add(new Termin.fromJSON(entity));
    }
    return entries;
  }

  ///
  /// Return a single Termin in canonical view
  ///
  Future<Termin> getCalenderEntryById(String id) async {
    _actionExecution(APIAction.GET_CALENDAR);
    String response = await _APIConnection.getFromAPI(
        "termine/$id",
        null,
        _user.isLoggedIn() ? _user.getJWT() : null
    );
    var jsonResponse = json.decode(response)['entity'];
    return new Termin.fromJSON(jsonResponse);
  }

  ///
  /// Returns the next Calendar Entry
  ///
  Future<List<dynamic>> getNextCalendarEntries() async {
    _actionExecution(APIAction.GET_CALENDAR);
    await _cache.init("next", cacheDuration: 1000 * 60 * 60 * 24);
    if (_cache.hasCache()) {
      return jsonDecode(_cache.getCache())['entities'];
    }
    String response = await _APIConnection.getFromAPI(
        "termine", {"limit": "3", "view": "canonical", "orderby": "asc-start", "start": "gte-${(new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}"}, _user.isLoggedIn() ? _user.getJWT() : null);
    _cache.setCache(response);
    return jsonDecode(response)['entities'];
  }

  ///
  /// Returns calendar entries which occur "soon"
  ///
  Future<List<dynamic>> getCalendarEntriesSoon(int page) async {
    _actionExecution(APIAction.GET_CALENDAR);
    await _cache.init("soon${page.toString()}",
        cacheDuration: 1000 * 60 * 60 * 24);
    if (_cache.hasCache()) {
      return jsonDecode(_cache.getCache())['entities'];
    }
    String response = await _APIConnection.getFromAPI("termine",
        {"limit": "20", "offset": (page * 20).toString(), "view": "canonical", "orderby": "asc-start", "start": "gte-${(new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}"}, _user.isLoggedIn() ? _user.getJWT() : null);
    _cache.setCache(response);
    return jsonDecode(response)['entities'];
  }

  ///
  /// Returns Holiday Timestamp
  ///
  /// Cache is not validated here because it is validated afterwards by checking if the holidays already began
  ///
  Future<int> getHolidayUnixTimestamp() async {
    _actionExecution(APIAction.GET_CALENDAR);
    await _cache.init("holiday");
    if (_cache.hasCache(validate: false)) {
      String cached = _cache.getCache();
      int cachedI = int.parse(cached);
      if (cachedI > new DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        return cachedI;
      } else {
        _cache.delete();
      }
    }
    var jsonResponse = jsonDecode(await _APIConnection.getFromAPI(
        "termine",
        {
          "limit": "1",
          "tags": "eq-6spaDnbYlZttaWosETA8vU",
          "stop": "gte-${new DateTime.now().millisecondsSinceEpoch ~/ 1000}",
          "view": "runtime",
          "orderby": "asc-start"
        },
        _user.isLoggedIn() ? _user.getJWT() : null))['entities'];
    if (jsonResponse.length > 0) {
      String response = jsonResponse[0]['start'].toString();
      _cache.setCache(response);
      return int.parse(response);
    }
    return 0;
  }

  ///
  /// Returns RPlan
  /// Date specified as method
  /// If teacher is null all will be shown
  ///
  Future<String> getRAWRPlan(String teacherType, String teacher, {bool force=false}) async {
    _actionExecution(APIAction.GET_RPLAN_TODAY);
    Map<String, String> params = {};
    var day = await _getIDForRPlanDay();
    if (day == null) return null;

    if (teacher != null) {
      params[teacherType] = "eq-${Uri.encodeComponent(teacher)}";
    }

    params["orderby"] = "asc-stunde";
    params["vplan"] = "eq-$day";
    params["view"] = "canonical";
    params["limit"] = "100";

    await _cache.init(params.toString());
    if (force) _cache.delete();
    if (_cache.hasCache()) {
      return _cache.getCache();
    }
    String response = await _APIConnection.getFromAPI(
        "vertretungen", params, _user.getJWT());
    _cache.setCache(response);
    return response;
  }

  ///
  /// Returns the ID for the current Action of the RPlan
  /// This ID is needed to filter for days
  ///
  /// This Method does not use a cache, because it is only called if the RPlan Method does not contain a cache.
  ///
  Future <String> _getIDForRPlanDay() async {
    _actionExecution(APIAction.GET_RPLAN_TODAY);

    int days;
    if (_endpoint == APIAction.GET_RPLAN_TODAY) {
      days = 0;
    } else if (_endpoint == APIAction.GET_RPLAN_TOMORROW) {
      days = DateTime.now().weekday > 5 ?  1 + (8-DateTime.now().weekday) : 1;
    } else {
      days = DateTime.now().weekday > 5 ?  2 + (8-DateTime.now().weekday) : 2;
    }
    // Calculating today at 8o clock
    DateTime now = new DateTime.now();
    DateTime requestTime = new DateTime(now.year, now.month, now.day, 8, 0, 0, 0, 0);
    // Adding the days
    int time = requestTime.millisecondsSinceEpoch ~/ 1000 + (days * 86400);
    String response = await _APIConnection.getFromAPI(
        "vplans", {"date": "gte-$time","orderby": "asc-date"}, _user.getJWT());
    List<dynamic> jsonResponse = jsonDecode(response)["entities"];
    if (jsonResponse != null && jsonResponse.length > 0) {
      return jsonResponse[0]['id'];
    }
    return null;
  }

  ///
  /// Returns specified information of user
  /// Info needs a LDAP field name(s)
  /// E.g. employeeNumber, givenName, sn etc.
  ///
  /// It directly returns the Information as String
  ///
  Future <String> getUserInfo() async {
    _actionExecution(APIAction.GET_USER_INFO);
    await _cache.init("${_user.getUsername()}");
    String response;
    if (_cache.hasCache()) {
      response = _cache.getCache();
    } else {
      response = await _APIConnection.getFromAPI(
          "users/${_user.getUsername()}", null, _user.getJWT());
      _cache.setCache(response);
    }
    if (response != null) {
      return response;
    }
    return null;
  }

  Future <String> getArticles({int page=0}) async {
    _actionExecution(APIAction.GET_ARTICLE);
    Map<String, String> params = {};
    params['view'] = "preview-with-image";
    params['tags'] = "eq-5uxbYvmfyVLejcyMSD4lMu";
    params['orderby'] = "desc-changed";
    params['limit'] = 25.toString();
    params['offset'] = (25 * page).toString();

    String response = await _APIConnection.getFromAPI("articles", params, _user.isLoggedIn() ? _user.getJWT() : null);
    if (response != null) {
      return response;
    }
    return "";
  }

  Future <String> getArticle(String id) async {
    _actionExecution(APIAction.GET_ARTICLE);

    String response = await _APIConnection.getFromAPI("articles/$id", null, _user.isLoggedIn() ? _user.getJWT() : null);
    if (response != null) {
      return response;
    }
    return "";
  }


}

class _CacheManager {
  _CacheManager(this._action);

  // Creating this at the loading of CacheManager to not cause weird errors with too little time left
  int time = DateTime.now().millisecondsSinceEpoch;
  final APIAction _action;
  String _type;
  int _duration;
  File _file;
  String _contents;

  ///
  /// Initialize Cache
  ///
  /// Type: Specific type: e.g. the date for RPlan, nextEvents for nextEvents in Calender etc.
  /// Cache Duration: If the standard Cache Duration should not be used. Eg. for Holiday Time
  Future init(String type, {int cacheDuration}) async {
    _type = type;
    _duration = cacheDuration;
    if (_duration == null) {
      _duration = _getDuration();
    }
    if (!kIsWeb) {
      _file = File((await getTemporaryDirectory()).path + // ignore: prefer_interpolation_to_compose_strings
          "/" +
          _action.toString() +
          "/" +
          base64.encode(utf8.encode(type)) +
          ".json");
    }
  }

  ///
  /// Check if Cache exists and is valid
  ///
  bool hasCache({bool validate=true}) {
    if (_type == null) throw Exception("Cache has not been initialized.");
    // Deactivate Cache for Debug Mode
    if (foundation.kDebugMode) return false;
    // Do not cache in Web.
    if (kIsWeb) return false;
    if (!(_file.existsSync())) return false;
    if (_contents == null) _contents = _file.readAsStringSync();
    return validate == false ? true : jsonDecode(_contents)['created'] + _duration > time;
  }

  ///
  /// Return Cache.
  /// Warning: This will not check validity
  ///
  String getCache() {
    if (_type == null) throw Exception("Cache has not been initialized.");
    if (_file == null || !(_file.existsSync())) return null;
    if (_contents == null) _contents = _file.readAsStringSync();
    return jsonDecode(_contents)['content'];
  }

  ///
  /// Set Cache.
  ///
  void setCache(String content) {
    if (_type == null) throw Exception("Cache has not been initialized.");
    if (_file == null) return;
    _file.createSync(recursive: true);
    _contents = jsonEncode({"created": time, "content": content});
    _file.writeAsStringSync(_contents, flush: true);
  }

  ///
  /// Will delete the cache
  ///
  void delete() {
    if (_type == null) throw Exception("Cache has not been initialized.");
    if (_file.existsSync()) {
      _file.deleteSync();
    }
  }

  ///
  /// Returning duration of cache
  /// GET_USERNAME and GET_GROUPS will not be cached, due to more effort caching than actually getting.
  ///
  int _getDuration() {
    switch (_action) {
      case APIAction.GET_USERNAME:
        return 0;
      case APIAction.GET_GROUPS:
        return 0;
      case APIAction.GET_CALENDAR:
        return 1000 * 60 * 2;
      case APIAction.GET_RPLAN_TODAY:
        return 1000 * 60 * 2;
      case APIAction.GET_RPLAN_TOMORROW:
        return 1000 * 60 * 2;
      case APIAction.GET_RPLAN_DAYAFTERTOMMOROW:
        return 1000 * 60 * 2;
      case APIAction.GET_USER_INFO:
        return 1000 * 60 * 2;
      case APIAction.GET_ARTICLE:
        return 0;
    }
    return 0;
  }

}

// API Types

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