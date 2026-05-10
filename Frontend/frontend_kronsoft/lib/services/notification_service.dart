import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Cere permisiuni
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisiuni notificari acordate');
    }

    // Obtine FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handler cand app e in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificare primita: ${message.notification?.title}');
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}