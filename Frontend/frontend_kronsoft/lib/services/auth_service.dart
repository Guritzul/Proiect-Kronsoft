import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  // Uses the same backend config as ApiService
  String get baseUrl => '${BackendConfig.baseUrl}/auth';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _syncWithBackend();
    return credential;
  }

  Future<UserCredential> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _syncWithBackend();
    return credential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> _syncWithBackend() async {
  try {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) return;
    await http.post(
      Uri.parse('$baseUrl/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    // Ignora eroarea de sync, loginul Firebase a reusit
  }
}

  User? get currentUser => _auth.currentUser;
}