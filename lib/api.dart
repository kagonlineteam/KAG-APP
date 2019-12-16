import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as Foundation;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// Calls setLoginCredentials in User
  ///
  Future<bool> setLoginCredentials(String username, String password) async {
    _user.setLoginCredentials(username, password);
    return await _user.login();
  }
}

class _User {
  String _jwt;

  ///
  /// Checks if user is loggedin
  /// Does check if log in is valid, too
  ///
  bool isLoggedIn() {
    if (_jwt != null &&
        getDecodedJWT()['exp'] <
            (new DateTime.now().millisecondsSinceEpoch / 1000)) {
      return true;
    }
    return false;
  }

  ///
  /// Saves username and password
  /// (Does not login)
  ///
  void setLoginCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    prefs.setString("password", password);
  }

  ///
  /// Login to API
  /// Gets jwt and saves it to variable
  /// Loads username/password from save if needed
  ///
  /// Returns if login successful
  ///
  Future<bool> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _jwt = await _APIConnection.getJWTFromLogin(
        prefs.getString("username"), prefs.getString("password"));
    if (_jwt == null) return false;
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
}

class _APIConnection {
  static const API = "https://apiv2.kag-langenfeld.de/";

  ///
  /// Makes Login request.
  /// Return JWT if successful else null
  ///
  static Future<String> getJWTFromLogin(String username,
      String password) async {
    var loginBody = jsonEncode(
        {"username": username, "password": password, "client": "appclient"});
    var response = await http.post(API + "login", body: loginBody,
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
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
    return (await http.get("${API}$path$query",
        headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null))
        .body;
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
  /// Returns raw JSON calendar entries output
  ///
  /// If start and end are null: All will be shown
  ///
  Future<String> getRAWCalendar(int start, int end) async {
    _actionExecution(APIAction.GET_CALENDAR);
    await _cache.init("$start-$end");
    if (_cache.hasCache()) {
      return _cache.getCache();
    }
    String response = await _APIConnection.getFromAPI(
        "termine",
        start != null && end != null
            ? {"start%5B$start%5D": "gte", "end%5B$end%5B": "lte"}
            : null,
        _user.getJWT());
    _cache.setCache(response);
    return response;
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
        "termine", {"limit": "3", "view": "canonical", "orderby": "asc-start", "start": "gte-" + (new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}, _user.getJWT());
    _cache.setCache(response);
    return jsonDecode(response)['entities'];
  }

  ///
  /// Returns calendar entries which occur "soon"
  ///
  Future<List<dynamic>> getCalendarEntriesSoon(int page) async {
    _actionExecution(APIAction.GET_CALENDAR);
    await _cache.init("soon" + page.toString(),
        cacheDuration: 1000 * 60 * 60 * 24);
    if (_cache.hasCache()) {
      return jsonDecode(_cache.getCache())['entities'];
    }
    String response = await _APIConnection.getFromAPI("termine",
        {"limit": "20", "offset": (page * 20).toString(), "view": "canonical", "orderby": "asc-start", "start": "gte-" + (new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}, _user.getJWT());
    _cache.setCache(response);
    return jsonDecode(response)['entities'];
  }

  ///
  /// Returns Holiday Timestamp
  ///
  /// Note: Please do not use this as example how to use cache
  ///
  Future<int> getHolidayUnixTimestamp() async {
    _actionExecution(APIAction.GET_CALENDAR);
    await _cache.init("holiday");
    String cached = _cache.getCache();
    if (cached != null) {
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
        _user.getJWT()))['entities'];
    if (jsonResponse.length > 0) {
      String response = jsonResponse[0]['start'].toString();
      _cache.setCache(response);
      return int.parse(response);
    }
    return 0;
  }

  ///
  /// Return RPLAN
  /// Date specified as method
  /// If teacher is null all will be shown
  ///
  Future<String> getRAWRPlan(String teacherType, String teacher, {force: false}) async {
    _actionExecution(APIAction.GET_RPLAN_TODAY);
    Map<String, String> params = {};
    var day = await getIDForRPlanDay(_endpoint);
    if (day == null) return null;

    if (teacher != null) {
      params[teacherType] = "eq-"+teacher;
    }
    await _cache.init(params.toString());
    if (force) _cache.delete();
    if (_cache.hasCache()) {
      return _cache.getCache();
    }

    params["vplan"] = "eq-" + day;
    params["view"] = "canonical";
    String response = await _APIConnection.getFromAPI(
        "vertretungen", params, _user.getJWT());
    _cache.setCache(response);
    return response;
  }

  Future <String> getIDForRPlanDay(APIAction action) async {
    String response = await _APIConnection.getFromAPI(
        "vplans", {"date": "gte-${(new DateTime.now().millisecondsSinceEpoch ~/ 1000) - 86400}"}, _user.getJWT());
    var jsonResponse = jsonDecode(response)["entities"];

    if (action == APIAction.GET_RPLAN_TODAY && jsonResponse.length > 0) {
      return jsonResponse[0]["id"];
    } else if (action == APIAction.GET_RPLAN_TOMORROW && jsonResponse.length > 1) {
      return jsonResponse[1]["id"];
    } else if (jsonResponse.length > 0) {
      return jsonResponse[2]["id"];
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

  Future <String> getArticles() async {
    _actionExecution(APIAction.GET_ARTICLE);
    Map<String, String> params = {};
    params['view'] = "canonical";
    params['tags'] = "eq-5uxbYvmfyVLejcyMSD4lMu";

    String response = await _APIConnection.getFromAPI("articles", params, null);
    if (response != null) {
      return response;
    }
    return "";
  }

  Future <String> getArticle(String id) async {
    _actionExecution(APIAction.GET_ARTICLE);

    String response = await _APIConnection.getFromAPI("articles/$id", null, null);
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
  APIAction _action;
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
    this._type = type;
    this._duration = cacheDuration;
    if (_duration == null) {
      _duration = _getDuration();
    }
    _file = File((await getTemporaryDirectory()).path +
        "/" +
        _action.toString() +
        "/" +
        type +
        ".json");
  }

  ///
  /// Check if Cache exists and is valid
  ///
  bool hasCache() {
    if (_type == null) throw Exception("Cache has not been initialized.");
    // Deactivate Cache for Debug Mode
    if (Foundation.kDebugMode) return false;
    if (!(_file.existsSync())) return false;
    if (_contents == null) _contents = _file.readAsStringSync();
    return jsonDecode(_contents)['created'] + _duration > time;
  }

  ///
  /// Return Cache.
  /// Warning: This will not check validity
  ///
  String getCache() {
    if (_type == null) throw Exception("Cache has not been initialized.");
    if (!(_file.existsSync())) return null;
    if (_contents == null) _contents = _file.readAsStringSync();
    return jsonDecode(_contents)['content'];
  }

  ///
  /// Set Cache.
  ///
  void setCache(String content) {
    if (_type == null) throw Exception("Cache has not been initialized.");
    _file.createSync(recursive: true);
    _contents = jsonEncode({"created": time, "content": content});
    _file.writeAsStringSync(_contents, flush: true);
  }

  ///
  /// Will delete the cache
  ///
  void delete() {
    if (_type == null) throw Exception("Cache has not been initialized.");
    _file.deleteSync();
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
        return 1000 * 60 * 60 * 24 * 3;
      case APIAction.GET_RPLAN_TODAY:
        return 1000 * 60 * 5;
      case APIAction.GET_RPLAN_TOMORROW:
        return 1000 * 60 * 20;
      case APIAction.GET_RPLAN_DAYAFTERTOMMOROW:
        return 1000 * 60 * 60;
      case APIAction.GET_USER_INFO:
        return 1000 * 60 * 60 * 24 * 7;
      case APIAction.GET_ARTICLE:
        return 0;
    }
    return 0;
  }
}
