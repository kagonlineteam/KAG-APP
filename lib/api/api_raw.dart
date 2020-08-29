import 'dart:convert';

import 'package:http/http.dart' as http;

import '../main.dart';

const API = "https://api.kag-langenfeld.de/";

///
/// Makes Login request.
/// Returns an Object with token and refresh token
///
Future<Map<String, String>> login(String username, String password) async {
  var loginBody = jsonEncode(
      {"username": username, "password": password, "client": "appclient"});
  var response = await http.post("${API}login?type=refresh",
      body: loginBody, headers: {"Content-Type": "application/json"});
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
Future<Map<String, String>> refreshLogin(
    String username, String refreshToken) async {
  var loginBody = jsonEncode({
    "username": username,
    "refresh_token": refreshToken,
    "client": "appclient"
  });
  var response = await http.post("${API}refresh?type=refresh",
      body: loginBody, headers: {"Content-Type": "application/json"});
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
Future<String> getFromAPI(
    String path, Map<String, String> params, String jwt) async {
  String query = "";
  if (params != null) {
    query = "?";
    params.forEach((name, value) {
      if (query != "?") query += "&";
      query += "$name=$value";
    });
  }
  KAGApp.app.setLoading();
  var request = (await http.get("$API$path$query",
          headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null))
      .body;
  KAGApp.app.setLoading(loading: false);
  return request;
}