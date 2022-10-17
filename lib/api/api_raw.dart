import 'dart:convert';

import 'package:http/http.dart' as http;

const API = "api.kag-langenfeld.de";

// This is here so it is possible to have a mock client
http.Client client = http.Client();

///
/// Makes Login request.
/// Returns an Object with token and refresh token
///
Future<Map<String, String>> login(String username, String password) async {
  var loginBody = jsonEncode(
      {"username": username, "password": password, "client": "appclient"});
  var response = await client.post(Uri.https(API, "login", {"type": "refresh"}),
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
  var response = await client.post(Uri.https(API, "refresh", {"type": "refresh"}),
      body: loginBody, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    return {"token": res['access_token'], "refresh": res['refresh_token']};
  }
  return null;
}

Future<bool> logout(String refreshToken) async {
  var response = await client.post(Uri.https(API, "logout"),
      body: jsonEncode({
        "refresh_token": refreshToken
      }),
      headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

///
/// GET from API
/// Makes request, returns response body
/// If not successful returns null
/// Will not send authorization header if jwt is null
///
Future<String> getFromAPI(
    String path, Map<String, String> params, String jwt) async {
  // Check that app is not null. So that tests work
  var response = await client.get(Uri.https(API, path, params),
          headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null);
  if (response.statusCode != 200) throw Exception("HTTP Status is not 200");
  return response.body;
}

Future<String> postToAPI(String path, Map<String, String> params, String body, String jwt) async {
  response = await client.post(Uri.https(API, path, params),
    headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null,
    body: body);
  if (response.statusCode != 200) throw Exception("HTTP Status is not 200");
  return response.body;
}

Future<String> putToAPI(
    String path, Map<String, String> params, String body, String jwt) async {
  var response = await client.put(Uri.https(API, path, params),
      headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null,
      body: body);
  if (response.statusCode != 200) throw Exception("HTTP Status is not 200");
  return response.body;
}

///
/// Sends an empty Post Request to API
/// Makes request, returns response body
/// If not successful returns null
/// Will not send authorization header if jwt is null
///
Future<String> sendEmptyPostToAPI(
    String path, Map<String, String> params, String jwt) async {
  // Check that app is not null. So that tests work
  var response = await client.post(Uri.https(API, path, params),
      headers: jwt != null ? {"Authorization": "Bearer $jwt"} : null);
  if (response.statusCode != 200) throw Exception("HTTP Status is not 200");
  return response.body;
}

///
/// Sends a request to the webmail server, not the api server.
/// This includes the JWT for authentication
///
Future<String> getWebmailHash(String jwt) async {
  // Check that app is not null. So that tests work
  var response = await client.post(Uri.https("webmail.kag-langenfeld.de", "app.php", null), body: jsonEncode({"token": jwt}), headers: {"Content-Type": "application/json"});
  if (response.statusCode != 200) throw Exception("HTTP Status is not 200");
  return response.body;
}