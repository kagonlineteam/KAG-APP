import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_models.dart' as models;
import 'api_raw.dart' as http;

enum APIAction {
  GET_USERNAME,
  GET_GROUPS,
  GET_CALENDAR,
  GET_VPLAN,
  GET_USER_INFO,
  GET_ARTICLE

}

class API {
  _User _user;
  _APIRequests _requests;

  API() {
    _user = _User();
    _requests = new _APIRequests(this);
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
      case APIAction.GET_VPLAN:
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
  /// Calls setLoginCredentials in User
  ///
  Future<bool> setLoginCredentials(String username, String password) async {
    return await _user.setLoginCredentials(username, password);
  }

  _APIRequests get requests => _requests;
}

class _APIRequests {
  APIAction _endpoint;
  API _api;

  ///
  /// Handles Request, checks parameter etc.
  /// Login status should be already checked.
  /// Throws exception if different method is executed than specified as Action
  ///
  _APIRequests(API api) {
    _api = api;
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
  Future _actionExecution(APIAction action) async {
    if (_api._isLogInNeeded(action) && !_api._user.isLoggedIn()) {
      if (!await _api._user.login()) {
        throw Exception("Login to API is not possible");
      }
    }
  }

  ///
  /// Returns username
  ///
  Future<String> getUsername() async {
    await _actionExecution(APIAction.GET_USERNAME);
    return _api._user.getUsername();
  }

  ///
  /// Returns users groups
  ///
  Future<List> getGroups() async {
    await _actionExecution(APIAction.GET_GROUPS);
    return _api._user.getGroups();
  }

  ///
  /// Returns Termin entries for Month
  ///
  Future<List<models.Termin>> getCalendarForMonth(int month, int year) async {
    await _actionExecution(APIAction.GET_CALENDAR);
    int start = (new DateTime(year, month, 1).millisecondsSinceEpoch ~/ 1000);
    int end = (new DateTime(year, month + 1, 1).millisecondsSinceEpoch ~/ 1000);
    String response = await http.getFromAPI(
        "termine",
        {"start": "gte-$start", "stop": "lte-$end", "view": "runtime", "limit": "100"},
        _api._user.isLoggedIn() ? _api._user.getJWT() : null);
    var jsonResponse = json.decode(response)['entities'];
    List<models.Termin> entries = [];
    for (var entity in jsonResponse) {
      entries.add(new models.Termin.fromJSON(entity));
    }
    return entries;
  }

  ///
  /// Return a single Termin in canonical view
  ///
  Future<models.Termin> getCalenderEntryById(String id) async {
    await _actionExecution(APIAction.GET_CALENDAR);
    String response = await http.getFromAPI(
        "termine/$id",
        null,
        _api._user.isLoggedIn() ? _api._user.getJWT() : null
    );
    var jsonResponse = json.decode(response)['entity'];
    return new models.Termin.fromJSON(jsonResponse);
  }

  ///
  /// Returns the next Calendar Entry
  ///
  Future<List<dynamic>> getNextCalendarEntries() async {
    await _actionExecution(APIAction.GET_CALENDAR);
    String response = await http.getFromAPI(
        "termine", {"limit": "3", "view": "canonical", "orderby": "asc-start", "start": "gte-${(new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}"}, _api._user.isLoggedIn() ? _api._user.getJWT() : null);
    return jsonDecode(response)['entities'];
  }

  ///
  /// Returns calendar entries which occur "soon"
  ///
  Future<List<dynamic>> getCalendarEntriesSoon(int page) async {
    await _actionExecution(APIAction.GET_CALENDAR);
    String response = await http.getFromAPI("termine",
        {"limit": "20", "offset": (page * 20).toString(), "view": "canonical", "orderby": "asc-start", "start": "gte-${(new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}"}, _api._user.isLoggedIn() ? _api._user.getJWT() : null);
    return jsonDecode(response)['entities'];
  }

  ///
  /// Returns Holiday Timestamp
  ///
  /// Cache is not validated here because it is validated afterwards by checking if the holidays already began
  ///
  Future<int> getHolidayUnixTimestamp() async {
    await _actionExecution(APIAction.GET_CALENDAR);
    var jsonResponse = jsonDecode(await http.getFromAPI(
        "termine",
        {
          "limit": "1",
          "tags": "eq-6spaDnbYlZttaWosETA8vU",
          "stop": "gte-${new DateTime.now().millisecondsSinceEpoch ~/ 1000}",
          "view": "runtime",
          "orderby": "asc-start"
        },
        _api._user.isLoggedIn() ? _api._user.getJWT() : null))['entities'];
    if (jsonResponse.length > 0) {
      String response = jsonResponse[0]['start'].toString();
      return int.parse(response);
    }
    return 0;
  }

  ///
  /// Returns RPlan
  /// Date specified as method
  /// If teacher is null all will be shown
  ///
  /// param day should be a integer value 0 to 2
  ///
  /// TODO When returning the object in future it should return the calculated date, too
  Future<String> getRAWRPlan(String teacherType, String teacher, int day, {bool force=false}) async {
    await _actionExecution(APIAction.GET_VPLAN);
    Map<String, String> params = {};
    var vplan = await _getIDForRPlanDay(day);
    if (vplan == null) return null;

    if (teacher != null) {
      params[teacherType] = "eq-${Uri.encodeComponent(teacher)}";
    }

    params["orderby"] = "asc-stunde";
    params["vplan"] = "eq-$vplan";
    params["view"] = "canonical";
    params["limit"] = "100";

    String response = await http.getFromAPI(
        "vertretungen", params, _api._user.getJWT());
    return response;
  }

  ///
  /// Returns the ID for the current Action of the RPlan
  /// This ID is needed to filter for days
  ///
  Future<String> _getIDForRPlanDay(int day) async {

    int days;
    if (day == 0) {
      days = 0;
    } else if (day == 1) {
      days = DateTime.now().weekday > 5 ?  1 + (8-DateTime.now().weekday) : 1;
    } else {
      days = DateTime.now().weekday > 5 ?  2 + (8-DateTime.now().weekday) : 2;
    }
    // Calculating today at 8o clock
    DateTime now = new DateTime.now();
    DateTime requestTime = new DateTime(now.year, now.month, now.day, 8, 0, 0, 0, 0);
    // Adding the days
    int time = requestTime.millisecondsSinceEpoch ~/ 1000 + (days * 86400);
    var plans = jsonDecode(await http.getFromAPI("vplans", {"date": "eq-${time.toString()}"}, _api._user.getJWT()));
    if (plans['entities'].length == 0) return null;
    return plans['entities'][0]['id'];
  }

  ///
  /// Returns specified information of user
  /// Info needs a LDAP field name(s)
  /// E.g. employeeNumber, givenName, sn etc.
  ///
  /// It directly returns the Information as String
  ///
  Future <String> getUserInfo() async {
    await _actionExecution(APIAction.GET_USER_INFO);
    String response;
    response = await http.getFromAPI(
        "users/${_api._user.getUsername()}", null, _api._user.getJWT());
    return response;
  }

  Future <String> getArticles({int page=0}) async {
    await _actionExecution(APIAction.GET_ARTICLE);
    Map<String, String> params = {};
    params['view'] = "preview-with-image";
    params['tags'] = "eq-5uxbYvmfyVLejcyMSD4lMu";
    params['orderby'] = "desc-changed";
    params['limit'] = 25.toString();
    params['offset'] = (25 * page).toString();

    String response = await http.getFromAPI("articles", params, _api._user.isLoggedIn() ? _api._user.getJWT() : null);
    if (response != null) {
      return response;
    }
    return "";
  }

  Future <String> getArticle(String id) async {
    await _actionExecution(APIAction.GET_ARTICLE);

    String response = await http.getFromAPI("articles/$id", null, _api._user.isLoggedIn() ? _api._user.getJWT() : null);
    if (response != null) {
      return response;
    }
    return "";
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
    var obj = await http.login(
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
      await Future.doWhile(() async {
        await Future.delayed(Duration(seconds: 1));
        return _loggingIn;
      });
      return isLoggedIn();
    }
    // This variable has to be set at any return.
    //TODO This does not seem like the perfect way to do this
    _loggingIn = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if the saved JWT is still valid if none is cached (This has to be done because a new jwt can not be issued before the old one is expired)
    if (_jwt == null) {
      _jwt = await prefs.getString("token");
      if (isLoggedIn()) {
        _loggingIn = false;
        return true;
      }
    }
    // Load Refresh from disk if not cached
    if (_refreshJWT == null) {
      _refreshJWT = prefs.getString("refresh");
      // We don't even need to try to login without refresh
      if (_refreshJWT == null) {
        _loggingIn = false;
        return false;
      }
    }
    var obj = await http.refreshLogin(
        prefs.getString("username"), _refreshJWT);
    if (obj == null) {
      _loggingIn = false;
      return false;
    }
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