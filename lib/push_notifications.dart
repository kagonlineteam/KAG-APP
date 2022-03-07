import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void parseMessage(RemoteMessage message) {
    if (message != null && message.data.containsKey("open")) {
      if (message.data['open'] == "splan") {
        //TODO RELOAD
        if (KAGAppState.app.type == AppType.NORMAL || KAGAppState.app.type == AppType.NORMAL_WITH_WEBMAIL) KAGAppState.app.goToPage(3);
      }
      else if (message.data['open'] == "vplan") {
        //TODO RELOAD
        if (KAGAppState.app.type == AppType.NORMAL || KAGAppState.app.type == AppType.NORMAL_WITH_WEBMAIL) KAGAppState.app.goToPage(4);
      } else if (message.data['open'] == "webmail") {
        if (KAGAppState.app.type == AppType.NORMAL_WITH_WEBMAIL) KAGAppState.app.goToPage(5);
      }
    }
  }
}