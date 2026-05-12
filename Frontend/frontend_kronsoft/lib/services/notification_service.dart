import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification permissions granted');
    }

    // Nu asteptam dupa token pentru ca poate dura mult sau poate ingheta daca nu e internet
    _messaging.getToken().then((token) {
      debugPrint('FCM Token: $token');
    }).catchError((e) {
      debugPrint('Error getting token: $e');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notification received: ${message.notification?.title}');
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
