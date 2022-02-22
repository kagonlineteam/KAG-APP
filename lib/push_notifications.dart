import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationsManager {

  static const String SP_FIREBASE_TOKEN = "firebase_token";

  FirebaseMessaging _firebaseMessaging;
  bool _initialized = false;

  Future<void> init() async {
    print("Called init Push Notifications");
    if (!_initialized) {
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;
      // For iOS request permission first.
      await _firebaseMessaging.requestPermission();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken(
        vapidKey: "BDhqS5XUllVp_ZfI20AyUSR-f2pE86wXSLrZgFxFx4U_ssfB81LoRtCNlm-AfJThyBaN1mmdKOv_4nD7OsJwuM8"
      );

      SharedPreferences.getInstance().then((sp) => sp.setString(SP_FIREBASE_TOKEN, token));
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }
}