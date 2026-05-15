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
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Initializam serviciile de notificari dar nu blocam pornirea aplicatiei daca unul esueaza
    await NotificationService().initialize().catchError((e) {
      debugPrint('Error initializing FCM: $e');
    });
    await LocalNotificationService.initialize().catchError((e) {
      debugPrint('Error initializing local notifications: $e');
    });
    await LocalNotificationService.scheduleDailyExerciseNotification().catchError((e) {
      debugPrint('Error scheduling exercise notification: $e');
    });

    LocalNotificationService.onNotificationTapped.stream.listen((payload) {
      _showNotificationDialog(payload);
    });
  } catch (e) {
    debugPrint('Critical error during initialization: $e');
  }

  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void _showNotificationDialog(String payload) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  if (payload == 'exercise_reminder') {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.appColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Daily Exercises',
          style: TextStyle(
            color: ctx.appColors.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Don\'t forget to do your exercises today!',
              style: TextStyle(color: ctx.appColors.textPrimary, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.fitness_center, color: ctx.appColors.accentColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Stay Healthy',
                  style: TextStyle(
                    color: ctx.appColors.accentColor,
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
            child: Text('OK', style: TextStyle(color: ctx.appColors.accentColor)),
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
      backgroundColor: ctx.appColors.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          color: ctx.appColors.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: ctx.appColors.textPrimary, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.medication, color: ctx.appColors.accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                pillName,
                style: TextStyle(
                  color: ctx.appColors.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (dosage.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.scale, color: ctx.appColors.textPrimary, size: 18),
                const SizedBox(width: 8),
                Text(dosage, style: TextStyle(color: ctx.appColors.textPrimary)),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, color: ctx.appColors.textPrimary, size: 18),
              const SizedBox(width: 8),
              Text(time, style: TextStyle(color: ctx.appColors.textPrimary)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('OK', style: TextStyle(color: ctx.appColors.accentColor)),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          title: 'Health App',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
