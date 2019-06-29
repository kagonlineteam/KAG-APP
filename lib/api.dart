import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum APIAction {GET_USERNAME, GET_GROUPS, GET_CALENDAR, GET_RPLAN_TODAY, GET_RPLAN_TOMORROW, GET_RPLAN_DAYAFTERTOMMOROW, GET_USER_INFO}

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
    if (_jwt != null && getDecodedJWT()['exp'] < (new DateTime.now().millisecondsSinceEpoch / 1000)) {
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
    _jwt = await _APIConnection.getJWTFromLogin(prefs.getString("username"), prefs.getString("password"));
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
    return getDecodedJWT()['username'];
  }

  ///
  /// Returns jwt if exists
  ///
  String getJWT() {
    return _jwt;
  }

  getDecodedJWT() {
    String output = _jwt.split(".")[1].replaceAll('-', '+').replaceAll('_', '/');
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
  static const API = "https://api.kag-langenfeld.de/";

  ///
  /// Makes Login request.
  /// Return JWT if successful else null
  ///
  static Future<String> getJWTFromLogin(String username, String password) async {
    var loginBody = jsonEncode({"username": username, "password": password});
    var response = await http.post(API + "login", body: loginBody, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    }
    return null;
  }

  ///
  /// GET from API
  /// Makes request, returns response body
  /// If not successful returns null
  /// Will not send authorization header if jwt is null
  ///
  static Future<String> getFromAPI(String path, Map<String, String> params, String jwt) async {
    String query = "";
    if (params != null) {
      query = "?";
      params.forEach((name, value) {
        if (query != "?") query += "&";
        query += "$name=$value";
      });
    }
    return (await http.get("${API}v1/$path$query", headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null)).body;
  }

}

class _APIRequest {
  APIAction _endpoint;
  _User _user;
  ///
  /// Handles Request, checks parameter etc.
  /// Login status should be already checked.
  /// Throws exception if different method is executed than specified as Action
  ///
  _APIRequest(APIAction endpoint, _User user) {
    _endpoint = endpoint;
    _user = user;
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
    if (!(_endpoint == action || (_endpoint == APIAction.GET_RPLAN_TOMORROW && action == APIAction.GET_RPLAN_TODAY) || (_endpoint == APIAction.GET_RPLAN_DAYAFTERTOMMOROW && action == APIAction.GET_RPLAN_TODAY))) {
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
    return _APIConnection.getFromAPI("termine", start != null && end != null ? {"start%5B$start%5D": "gte", "end%5B$end%5B": "lte"} : null, _user.getJWT());
  }

  ///
  /// Returns the next Calendar Entry
  ///
  Future<Map<String, dynamic>> getNextCalendarEntry() async {
    _actionExecution(APIAction.GET_CALENDAR);
    return jsonDecode(await _APIConnection.getFromAPI("termine", {"limit": "1", "orderby%5Bstart%5D": "asc", "start%5B${new DateTime.now().millisecondsSinceEpoch ~/ 1000}%5D": "gte"}, _user.getJWT()))['entities'][0];
  }

  Future<int> getHolidayUnixTimestamp() async {
    _actionExecution(APIAction.GET_CALENDAR);
    return jsonDecode(await _APIConnection.getFromAPI("termine", {"limit": "1", "tags%5Bferien%5D": "like", "start%5B${new DateTime.now().millisecondsSinceEpoch ~/ 1000}%5D": "gte"}, _user.getJWT()))['entities'][0]['start'];
  }

  ///
  /// Return RPLAN
  /// Date specified as method
  /// If teacher is null all will be shown
  ///
  Future<String> getRAWRPlan(String teacher) async {
    _actionExecution(APIAction.GET_RPLAN_TODAY);
    Map<String, String> params = {};
    if (_endpoint == APIAction.GET_RPLAN_TODAY) params["file"] = "heute";
    if (_endpoint == APIAction.GET_RPLAN_TOMORROW) params["file"] = "morgen";
    if (_endpoint == APIAction.GET_RPLAN_DAYAFTERTOMMOROW) params["file"] = "uebermorgen";
    if (teacher != null) {
      params["abbreviation"] = teacher;
    }
    return _APIConnection.getFromAPI("vplan", params, _user.getJWT());
  }

  ///
  /// Returns specified information of user
  /// Info needs a LDAP field name
  /// E.g. employeeNumber, givenName, sn etc.
  ///
  /// It directly returns the Information as String
  ///
  Future<String> getUserInfo(String info) async {
    _actionExecution(APIAction.GET_USER_INFO);
    String response = await _APIConnection.getFromAPI("users/${_user.getUsername()}", null, _user.getJWT());
    if (response != null) {
      final jResponse = jsonDecode(response);
      try {
        return jResponse['entity']['attributes'][info][0];
      } catch (e) {
        return null;
      }
    }
    return null;
  }


}