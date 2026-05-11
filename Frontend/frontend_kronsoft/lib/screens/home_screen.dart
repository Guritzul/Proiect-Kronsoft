import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color bgColor = Color(0xFF1a1a1a);
  static const Color accentColor = Color(0xFF4dd0e1);
  static const Color textColor = Color(0xFFe0e0e0);

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: accentColor, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Login reușit!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bun venit, ${user?.email ?? 'utilizator'}!',
              style: const TextStyle(fontSize: 16, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}