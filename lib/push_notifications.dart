import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {

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
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }
}