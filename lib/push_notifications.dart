import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Views/Calendar.dart';
import '../api/api.dart';
import '../api/api_models.dart';
import '../components/news.dart';
import 'app_type/app_type_managment.dart';
import 'main.dart';

class PushNotificationsManager {

  static const String SP_FIREBASE_TOKEN = "firebase_token";
  static const String TOPIC_ALL = "all";
  static const String TOPIC_LOGGED_IN = "logged_in";
  static const String TOPIC_APP_DEV = "app_dev";

  FirebaseMessaging _firebaseMessaging;
  bool _initialized = false;

  Future<void> init() async {
    print("Called init Push Notifications");
    if (!_initialized) {
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;
      _firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true);

      // For iOS request permission first.
      await _firebaseMessaging.requestPermission();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken(
        vapidKey: "BDhqS5XUllVp_ZfI20AyUSR-f2pE86wXSLrZgFxFx4U_ssfB81LoRtCNlm-AfJThyBaN1mmdKOv_4nD7OsJwuM8"
      );

      SharedPreferences.getInstance().then((sp) => sp.setString(SP_FIREBASE_TOKEN, token));
      print("FirebaseMessaging token: $token");

      _firebaseMessaging.getInitialMessage().then(parseMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(parseMessage);
      FirebaseMessaging.onMessage.listen(parseMessage);

      _initialized = true;
    }
  }

  void parseMessage(RemoteMessage message) async {
    if (message != null && message.data.containsKey("open")) {
      if (message.data['open'] == "splan") {
        //TODO RELOAD
        if (KAGAppState.app.appType == AppType.NORMAL) KAGAppState.app.goToPage(AppPage.SPLAN);
      }
      else if (message.data['open'] == "vplan") {
        //TODO RELOAD
        KAGAppState.app.goToPage(AppPage.RPLAN);
      } else if (message.data['open'] == "webmail") {
        KAGAppState.app.goToPage(AppPage.WEBMAIL);
      } else if (message.data['open'] == "article") {
        if (message.data['id'] != null) {
          Article article = await API.of(KAGAppState.app.context).requests.getArticle(message.data['id']);
          Navigator.push(KAGAppState.app.context, MaterialPageRoute(builder: (context) => ArticleDetailWidget(article)));
        }
      } else if (message.data['open'] == "termin") {
        if (message.data['id'] != null) {
          Termin termin = await API.of(KAGAppState.app.context).requests.getTermin(message.data['id']);
          Navigator.push(KAGAppState.app.context, MaterialPageRoute(builder: (context) => CalendarDetail(termin)));
        }
      }
    }
  }

  /**
   * Returns true for platforms we want to use
   * and initialize push notifications for
   */
  static bool isPushPlatform() {
    return !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  }
}