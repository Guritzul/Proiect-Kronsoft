import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Notificare in background: ${message.notification?.title}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisiuni notificari acordate');
    }

    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificare primita: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}