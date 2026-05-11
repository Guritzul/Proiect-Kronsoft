import 'package:firebase_messaging/firebase_messaging.dart';

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
      // Permisiuni notificari acordate
    }

    // Handler cand app e in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Notificare primita
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}