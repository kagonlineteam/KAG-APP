import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'api_helpers.dart' as helpers;
import 'api_models.dart' as models;
import 'api_raw.dart' as http;
import 'ios_mailconfig.dart';

const String SP_CACHE_USER_PRELOAD = "UserPreloadCache";

enum APIAction {
  GET_USERNAME,
  GET_GROUPS,
  GET_CALENDAR,
  GET_VPLAN,
  GET_USER_INFO,
  GET_ARTICLE,
  MAIL,
  GET_SPLAN,
  GET_EXAM,
  GET_HOMEWORK,
  SEND_KRANKMELDUNG
}

class API {
  // This is the internal user
  User _authenticationUser;
  // This is the data of the user in the API.
  // This user should always be loaded as it gets loaded on
  // app start, login and refresh
  models.KAGUser _userData = models.KAGUser("", "", "", "");
  _APIRequests _requests;

  API() {
    _authenticationUser = User();
    _requests = new _APIRequests(this);
  }

  API.asMock(User authenticationUser, _APIRequests requests) {
    _authenticationUser = authenticationUser;
    _requests = requests;
  }

  ///
  /// Of Method is used to get the API when APIHolder is used
  ///
  static API of(BuildContext context)  {
    return context.findAncestorWidgetOfExactType<helpers.APIHolder>().api;
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
      case APIAction.MAIL:
        return true;
      case APIAction.GET_SPLAN:
        return true;
      case APIAction.GET_EXAM:
        return true;
      case APIAction.GET_HOMEWORK:
        return true;
      case APIAction.SEND_KRANKMELDUNG:
        return false;
    }
    return true;
  }

  ///
  /// Returns if login credentials are saved
  /// This does not check its validity
  ///
  Future<bool> hasLoginCredentials() async {
    return await _authenticationUser._hasLoginCredentialsSaved();
  }


  ///
  /// Calls setLoginCredentials in User
  ///
  Future<bool> setLoginCredentials(String username, String password) async {
    bool success = await _authenticationUser.setLoginCredentials(username, password);
    if (success) await preloadUserData();
    return success;
  }

  ///
  /// Load User data into local variable.
  /// This should be called before the App starts.
  ///
  Future preloadUserData() async {
    if (await hasLoginCredentials()) {
      print("Loading user data.");
      try {
        _userData = await requests._getUserInfo();
      } on Exception catch (e) {
        print("Preloading user data not possible: ${e.toString()}");
        // In cases of no/bad network we load data from a local store
        // this could in theory lead to old data being loaded with other access
        // permissions than the newest version. This could be an inconvenience,
        // but should not be a security issue as security is not enforced on clientside.
        SharedPreferences sp = await SharedPreferences.getInstance();
        var decodedJson = utf8.decode(base64Decode(sp.getString(SP_CACHE_USER_PRELOAD)));
        _userData = models.KAGUser.fromJSON(jsonDecode(decodedJson)['entity']);
      }
    } else {
      print("User is not logged in: Not loading user data.");
    }
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
    if (_api._isLogInNeeded(action) && !_api._authenticationUser.isLoggedIn()) {
      if (await _api._authenticationUser.login()) {
        await _api.preloadUserData();
      } else {
        _api._authenticationUser.setLoginCredentials(null, null, callLogout: false); // We do not call Logout, because it is not a manual logout
        KAGAppState.app.setLoggedOut();
        throw Exception("Login to API is not possible");
      }
    }
  }

  ///
  /// Returns username
  ///
  Future<String> getUsername() async {
    await _actionExecution(APIAction.GET_USERNAME);
    return _api._authenticationUser.getUsername();
  }

  ///
  /// Returns users groups
  ///
  Future<List> getGroups() async {
    await _actionExecution(APIAction.GET_GROUPS);
    return _api._authenticationUser.getGroups();
  }

  ///
  /// Checks if user has Teacher permissions
  ///
  bool isTeacher() {
    return _api._userData.isTeacher;
  }

  ///
  /// Checks if user has Admin permissions
  ///
  bool isAdmin() {
    return _api._userData.isAdmin;
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
        _api._authenticationUser.isLoggedIn() ? _api._authenticationUser.getJWT() : null);
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
  Future<models.Termin> getTermin(String id) async {
    await _actionExecution(APIAction.GET_CALENDAR);
    String response = await http.getFromAPI(
        "termine/$id",
        null,
        _api._authenticationUser.isLoggedIn() ? _api._authenticationUser.getJWT() : null
    );
    var jsonResponse = json.decode(response)['entity'];
    return new models.Termin.fromJSON(jsonResponse);
  }

  ///
  /// Returns calendar entries which occur in the future
  ///
  helpers.ListResource<models.Termin> getFutureCalendarEntries() {
    return helpers.ListResource<models.Termin>.load("termine",
        {"view": "canonical", "orderby": "asc-start", "start": "gte-${(new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}"});
  }

  ///
  /// Returns the next Calendar Entry
  ///
  Future<List<models.Termin>> _getNextCalendarEntries() async {
    await _actionExecution(APIAction.GET_CALENDAR);
    var response = await http.getFromAPI(
        "termine", {"limit": "3", "view": "canonical", "orderby": "asc-start", "start": "gte-${(new DateTime.now().millisecondsSinceEpoch ~/ 1000).toString()}"}, _api._authenticationUser.isLoggedIn() ? _api._authenticationUser.getJWT() : null);
    if (response != null) {
      var jsonResponse = json.decode(response)['entities'];
      List<models.Termin> entries = [];
      for (var entity in jsonResponse) {
        entries.add(new models.Termin.fromJSON(entity));
      }
      return entries;
    }
    return [];
  }

  ///
  /// Returns Holiday Timestamp
  ///
  /// Cache is not validated here because it is validated afterwards by checking if the holidays already began
  ///
  Future<models.Termin> _getNextFerienEvent() async {
    await _actionExecution(APIAction.GET_CALENDAR);
    var jsonResponse = jsonDecode(await http.getFromAPI(
        "termine",
        {
          "limit": "1",
          "tags": "eq-6spaDnbYlZttaWosETA8vU",
          "start": "gte-${new DateTime.now().millisecondsSinceEpoch ~/ 1000}",
          "view": "runtime",
          "orderby": "asc-start"
        },
        _api._authenticationUser.isLoggedIn() ? _api._authenticationUser.getJWT() : null))['entities'];
    if (jsonResponse.length > 0) {
      return models.Termin.fromJSON(jsonResponse[0]);
    }
    return null;
  }

  ///
  /// Returns VPlan
  /// Date specified as method
  /// If teacher is null all will be shown
  ///
  /// param day should be a integer value 0 to 2
  ///
  Future<models.VPlan> getVPlan(String teacher, int day) async {
    await _actionExecution(APIAction.GET_VPLAN);
    Map<String, String> params = {};
    models.VPlan vplan = await _getVPlanObject(day);
    if (vplan == null) return models.VPlan.empty(day);

    if (isTeacher()) {
      params["orderby"] = "asc-v_lehrer,asc-stunde";
    } else {
      params["orderby"] = "asc-klasse,asc-stunde";
    }
    params["vplan"] = "eq-${vplan.id}";
    params["view"] = "canonical";
    params["limit"] = "100";

    if (teacher != null) {
      var paramsOne = Map.of(params);
      paramsOne.addAll({"lehrer": "eq-${Uri.encodeComponent(teacher)}"});
      await jsonDecode(await http.getFromAPI("vertretungen", paramsOne, _api._authenticationUser.getJWT()))['entities'].forEach((e) => vplan.addLesson(models.Lesson.fromJSON(e)));
      var paramsTwo = Map.of(params);
      paramsTwo.addAll({"v_lehrer": "eq-${Uri.encodeComponent(teacher)}"});
      await jsonDecode(await http.getFromAPI("vertretungen", paramsTwo, _api._authenticationUser.getJWT()))['entities'].forEach((e) => vplan.addLesson(models.Lesson.fromJSON(e)));
    } else {
      await jsonDecode(await http.getFromAPI("vertretungen", params, _api._authenticationUser.getJWT()))['entities'].forEach((e) => vplan.addLesson(models.Lesson.fromJSON(e)));
    }

    return vplan;
  }

  ///
  /// Returns the ID for the current Action of the RPlan
  /// This ID is needed to filter for days
  ///
  Future<models.VPlan> _getVPlanObject(int day) async {
    // Adding the days
    int time = helpers.getVPlanTime(day);
    var response  = jsonDecode(await http.getFromAPI("vplans", {"date": "eq-${time.toString()}", "view": "canonical"}, _api._authenticationUser.getJWT()))['entities'];
    if (response.length == 0) return null;
    return models.VPlan.fromJSON(response[0]);
  }

  ///
  /// Returns a KAGUser Object
  /// is used in preload function
  ///
  Future <models.KAGUser> _getUserInfo() async {
    await _actionExecution(APIAction.GET_USER_INFO);
    String response = await http.getFromAPI(
        "users/${_api._authenticationUser.getUsername()}", null, _api._authenticationUser.getJWT());
    var jsonResponse = jsonDecode(response)['entity'];
    // Yes I might actually use Base64 here for "security".
    // This is just to keep students to easily modify the local storage.
    // Everyone that wants to get around this would just recompile the app anywhere.
    SharedPreferences.getInstance().then((sp) => sp.setString(SP_CACHE_USER_PRELOAD, base64.encode(utf8.encode(response))));
    models.KAGUser user = models.KAGUser.fromJSON(jsonResponse);
    return user;
  }

  ///
  /// This loads the users data
  /// synchronous as it should already
  /// be preloaded
  ///
  models.KAGUser getUserInfo() {
    return _api._userData;
  }

  helpers.ListResource<models.Article> getNewsArticles() {
    // Not calling actionExecution here, because login not needed and needs async
    Map<String, String> params = {};
    params['view'] = "preview-with-image";
    params['tags'] = "eq-5uxbYvmfyVLejcyMSD4lMu";
    params['orderby'] = "desc-priority,desc-changed";

    return new helpers.ListResource<models.Article>.load("articles", params);
  }

  Future<models.Article> getArticle(String id) async {
    await _actionExecution(APIAction.GET_ARTICLE);

    String response = await http.getFromAPI("articles/$id", null, _api._authenticationUser.isLoggedIn() ? _api._authenticationUser.getJWT() : null);
    var jsonResponse = jsonDecode(response);
    if (!jsonResponse.containsKey('entity')) return null;
    return models.Article.fromJSON(jsonResponse['entity']);
  }


  Future <Uint8List> getFile(String id) async {
    var resp = await http.client.get(Uri.https(http.API, "files/$id"), headers: _api._authenticationUser.isLoggedIn() ? {'Authorization': 'Bearer ${_api._authenticationUser.getJWT()}'} : {});
    return resp.bodyBytes;
  }

  Future<helpers.HomeScreenData> getHomescreen() async {
    List<models.Termin> termine = await _getNextCalendarEntries();
    models.Termin ferien = await _getNextFerienEvent();
    List<models.Exam> exams = [];
    if (_api._authenticationUser.isLoggedIn() && _api._userData.isOberstufe) {
      exams = await _getUpcomingExams();
    }
    return helpers.HomeScreenData(termine, ferien, exams);
  }

  Future<models.MailSettings> getMailSettings() async {
    await _actionExecution(APIAction.MAIL);
    String response = await http.getFromAPI(
        "mail", null, _api._authenticationUser.getJWT());
   return models.MailSettings.fromJSON(jsonDecode(response));
  }

  Future<String> resetMailPassword() async {
    await _actionExecution(APIAction.MAIL);
    String response = await http.sendEmptyPostToAPI(
        "mail", null, _api._authenticationUser.getJWT());
    Map<String, dynamic> jsonResponse = jsonDecode(response);
    if (jsonResponse.containsKey("password")) {
      return jsonResponse['password'];
    } else {
      return null;
    }
  }

  Future<String> getMailAppPassword({int expireSeconds = -1}) async {
    await _actionExecution(APIAction.MAIL);
    String response = await http.sendEmptyPostToAPI(
        "mail/app", {
          "name": "custom-app-password-${DateTime.now().millisecondsSinceEpoch / 1000}",
           if (expireSeconds > 0) "time": expireSeconds.toString()
    }, _api._authenticationUser.getJWT());
    return jsonDecode(response)['password'];
  }

  Future<Mailconfig> getIOSMailConfig() async {
    await _actionExecution(APIAction.MAIL);
    String response = await http.sendEmptyPostToAPI(
        "mail/app", {"name": "ios-mailconfig-${DateTime.now().millisecondsSinceEpoch / 1000}"}, _api._authenticationUser.getJWT());
    String password = jsonDecode(response)['password'];
    return Mailconfig((await getMailSettings()).primaryMail, password, _api._authenticationUser.getUsername());
  }

  Future<models.SPlan> getUserSPlan() async {
    await _actionExecution(APIAction.GET_SPLAN);
    String response = await http.getFromAPI(
        "stundenplan", null, _api._authenticationUser.getJWT());
    return models.SPlan.fromJSON(jsonDecode(response));
  }

  Future<models.SPlan> getClassSPlan(String klasse) async {
    await _actionExecution(APIAction.GET_SPLAN);
    String response = await http.getFromAPI(
        "stundenplan/klasse/$klasse", null, _api._authenticationUser.getJWT());
    return models.SPlan.fromJSON(jsonDecode(response));
  }

  Future<models.SPlan> getRoomSPlan(String room) async {
    await _actionExecution(APIAction.GET_SPLAN);
    String response = await http.getFromAPI(
        "stundenplan/raum/$room", null, _api._authenticationUser.getJWT());
    return models.SPlan.fromJSON(jsonDecode(response));
  }

  ///
  /// Returns the upcoming exams
  ///
  Future<List<models.Exam>> _getUpcomingExams() async {
    await _actionExecution(APIAction.GET_EXAM);
    var response = await http.getFromAPI(
        "exams", {"view": "canonical", "orderby": "asc-date", "date": "gte-${((new DateTime.now().millisecondsSinceEpoch ~/ 1000) - 60*60*24).toString()}"}, _api._authenticationUser.getJWT());
    if (response != null) {
      var jsonResponse = json.decode(response)['entities'];
      return jsonResponse.map((exam) => models.Exam.fromJSON(exam)).toList().cast<models.Exam>();
    }
    return [];
  }

  ///
  /// Returns the hash for SSO to the webmail
  /// This needs to request the webmail, not the API
  ///
  Future<String> getWebmailHash() async {
    await _actionExecution(APIAction.MAIL);
    var response = await http.getWebmailHash(_api._authenticationUser._jwt);
    if (response != null) {
      Map<String, dynamic> jsonResponse = json.decode(response);
      if (jsonResponse.containsKey('hash')) return jsonResponse['hash'];
    }
    return "brokenhash"; // With a hash given that is invalid, the use can still just relogin
  }

  Future<List<models.Homework>> getMyHomeworks() async {
    await _actionExecution(APIAction.GET_HOMEWORK);
    var response = await http.getFromAPI(
        "homework/v1/my",
        {},
        _api._authenticationUser.getJWT()
    );
    if (response != null) {
      final List jsonResponse = json.decode(response)['entities'];
      return jsonResponse.map((homework) => models.Homework.fromJSON(homework)).toList().cast<models.Homework>();
    }
    return [];
  }

  Future<models.Homework> addHomework(String course, String task, int deadline) async {
    await _actionExecution(APIAction.GET_HOMEWORK);
    var response = await http.postToAPI(
      "homework/v1/homeworks",
      {},
      jsonEncode({
        "course": course,
        "task": task,
        "deadline": deadline
      }),
      _api._authenticationUser.getJWT()
    );
    if (response != null) {
      final jsonResponse = json.decode(response)['entitiy'];
      return jsonResponse;
    }
    return Future.error('Ein Fehler ist aufgetreten');
  }

  void editHomework(int id, String course, String task, int deadline) async {
    await _actionExecution(APIAction.GET_HOMEWORK);
    await http.putToAPI(
      "homework/v1/homeworks/$id",
      {"content-type": "application/json"},
      jsonEncode({
        "course": course,
        "task": task,
        "deadline": deadline
      }),
      _api._authenticationUser.getJWT()
    );
    return;
  }

  void reportHomework(int id) async {
    await _actionExecution(APIAction.GET_HOMEWORK);
    http.postToAPI("/homework/v1/report/$id", {}, jsonEncode({}), _api._authenticationUser.getJWT());
  }

  Future<bool> sendKrankmeldung(String sek, String name, String grade, String leader, String email, String remarks) async {
    await _actionExecution(APIAction.SEND_KRANKMELDUNG);
    var response = await http.postToAPI(
        '/krankmeldung/v1/krankmeldung',
        null,
        jsonEncode({
          "sek": sek,
          "name": name,
          if (sek == 'sek1') "klasse": grade,
          if (sek == 'sek1') "klassenleitung": leader,
          if (sek == 'sek2') "stufe": grade,
          if (sek == 'sek2') "stufenleitung": leader,
          "email": email,
          "bemerkungen": remarks
        }),
        null);
    return response != null;
  }
}

class User {
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
  Future<bool> setLoginCredentials(String username, String password, {bool callLogout=true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (password == null) {
      logout(callLogoutEndpoint: callLogout);
      return false;
    }
    prefs.setString("username", username);
    var obj = await http.login(
        prefs.getString("username"), password);
    if (obj == null) return false;
    _jwt = obj["token"];
    _refreshJWT = obj["refresh"];
    prefs.setString("token", _jwt);
    prefs.setString("refresh", _refreshJWT);
    return true;
  }

  Future logout({bool callLogoutEndpoint=true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // We need the refreshJWT for a proper logout
    if (_refreshJWT == null) {
      _refreshJWT = prefs.getString("refresh");
    }
    if (_refreshJWT != null && callLogoutEndpoint) { // No this should not be an else if
      http.logout(_refreshJWT);
    }
    prefs.remove("refresh");
    prefs.remove("username");
    prefs.remove("token");
    _refreshJWT = null;
    _jwt = null;
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
      // We do not need to try with a expired refresh token
      if (helpers.getDecodedJWT(_refreshJWT)['exp'] <= (new DateTime.now().millisecondsSinceEpoch / 1000)) {
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

  Map<dynamic, dynamic> getDecodedJWT() {
    return helpers.getDecodedJWT(_jwt);
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