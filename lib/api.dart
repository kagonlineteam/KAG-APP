enum APIAction {GET_USERNAME, GET_GROUPS, GET_CALENDAR, GET_RPLAN_TODAY, GET_RPLAN_TOMORROW, GET_RPLAN_DAYAFTERTOMMOROW}

class API {
  _User _user;


  ///
  /// Returns if endpoint needs Login
  /// Hardcoded to save data
  ///
  /// TODO Check if method in APIRequest exists
  ///
  bool _isLogInNeeded(APIAction action) {
    return false;
  }

  ///
  /// calls _isLogInNeeded to check if logIn is needed -> Logs in
  /// Returns APIRequest to user to allow executing method there.
  ///
  _APIRequest getAPIRequest(APIAction action) {
    return null;
  }


  ///
  /// Calls setLoginCredentials in User
  ///
  void setLoginCredentials(String username, String password) {

  }


}

class _User {
  String _jwt;

  ///
  /// Checks if user is loggedin
  /// Does check if log in is valid, too
  ///
  bool _isLoggedIn() {
    return false;
  }

  ///
  /// Saves username and password
  /// (Does not login)
  ///
  void setLoginCredentials(String username, String password) {

  }

  ///
  /// Login to API
  /// Gets jwt and saves it to variable
  /// Loads username/password from save if needed
  ///
  /// Returns if login successful
  ///
  bool login(_APIConnection api) {
    return false;
  }

  ///
  /// Returns groups of user.
  /// Null if not logged in.
  ///
  List<String> getGroups() {
    return null;
  }


  ///
  /// Read Username from jwt if exists
  /// Else read username from save
  ///
  String getUsername() {
    return null;
  }

  ///
  /// Returns jwt if exists
  ///
  String getJWT() {
    return null;
  }
}

class _APIConnection {
  static const API = "https://api.kag-langenfeld.de/";

  ///
  /// Makes Login request.
  /// Return JWT if successful else null
  ///
  static String getJWTFromLogin(String username, String password) {
    return null;
  }

  ///
  /// GET from API
  /// Makes request, returns response body
  /// If not successful returns null
  /// Will not send authorization header if jwt is null
  ///
  static String getFromAPI(Map<String, String> params, String jwt) {
    return null;
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
  void actionExecution(APIAction action) {

  }


  ///
  /// Returns username
  ///
  String getUsername() {
    return null;
  }

  ///
  /// Returns users groups
  ///
  List<String> getGroups() {
    return null;
  }

  ///
  /// Returns raw JSON calendar entries output
  ///
  String getRAWCalendar(int start, int end) {
    return null;
  }

  ///
  /// Return RPLAN
  /// Date specified as method
  ///
  String getRAWRPlan(String teacher) {
    return null;
  }


}