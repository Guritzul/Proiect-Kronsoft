import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/local_notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();
  await LocalNotificationService.initialize();
  await LocalNotificationService.scheduleDailyExerciseNotification();

  LocalNotificationService.onNotificationTapped.stream.listen((payload) {
    _showNotificationDialog(payload);
  });

  runApp(const MyApp());
}

void _showNotificationDialog(String payload) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  if (payload == 'exercise_reminder') {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Daily Exercises',
          style: TextStyle(
            color: Color(0xFF4dd0e1),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Don\'t forget to do your exercises today!',
              style: TextStyle(color: Color(0xFFe0e0e0), fontSize: 15),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.fitness_center, color: Color(0xFF4dd0e1), size: 18),
                SizedBox(width: 8),
                Text(
                  'Stay Healthy',
                  style: TextStyle(
                    color: Color(0xFF4dd0e1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF4dd0e1))),
          ),
        ],
      ),
    );
    return;
  }

  final parts = payload.split('|');
  if (parts.length < 5) return;

  final isReminder = parts[0] == 'pill_reminder';
  final pillName = parts[2];
  final dosage = parts[3];
  final time = parts[4];

  final String title = isReminder
      ? '⏰ Upcoming Pill'
      : '💊 Time to Take Your Pill!';
  final String message = isReminder
      ? 'You have $pillName scheduled at $time'
      : 'It\'s time to take $pillName — scheduled at $time';

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF4dd0e1),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(color: Color(0xFFe0e0e0), fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.medication, color: Color(0xFF4dd0e1), size: 18),
              const SizedBox(width: 8),
              Text(
                pillName,
                style: const TextStyle(
                  color: Color(0xFF4dd0e1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (dosage.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.scale, color: Color(0xFFe0e0e0), size: 18),
                const SizedBox(width: 8),
                Text(dosage, style: const TextStyle(color: Color(0xFFe0e0e0))),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFFe0e0e0), size: 18),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(color: Color(0xFFe0e0e0))),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK', style: TextStyle(color: Color(0xFF4dd0e1))),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
