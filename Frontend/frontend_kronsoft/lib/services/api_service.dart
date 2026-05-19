import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class BackendConfig {
  // Production Railway URL:
  static const String baseUrl =
      'https://proiect-kronsoft-backend-production.up.railway.app/api';
}

class ApiService {
  static String get baseUrl => BackendConfig.baseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final StreamController<void> allergenHistoryChanged =
      StreamController<void>.broadcast();

  static final StreamController<void> pillHistoryChanged =
      StreamController<void>.broadcast();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _get(String path) async {
    final res = await http
        .get(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw ApiException(res.statusCode, res.body);
  }

  Future<dynamic> _post(String path, [Map<String, dynamic>? body]) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : null;
    }
    throw ApiException(res.statusCode, res.body);
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final res = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : null;
    }
    throw ApiException(res.statusCode, res.body);
  }

  Future<dynamic> _delete(String path) async {
    final res = await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : null;
    }
    throw ApiException(res.statusCode, res.body);
  }

  Future<Map<String, dynamic>> getDashboard() async {
    return await _get('/dashboard');
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _get('/auth/profile');
  }

  Future<void> deleteAccount() async {
    await _delete('/auth/delete-account');
  }

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final token = await _auth.currentUser?.getIdToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/upload-avatar'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      await http.MultipartFile.fromPath('avatar', imageFile.path),
    );

    final res = await request.send().timeout(const Duration(seconds: 30));
    final responseData = await http.Response.fromStream(res);

    if (responseData.statusCode >= 200 && responseData.statusCode < 300) {
      return responseData.body.isNotEmpty
          ? jsonDecode(responseData.body)
          : null;
    }
    throw ApiException(responseData.statusCode, responseData.body);
  }

  Future<List<dynamic>> getPills() async {
    final data = await _get('/pills');
    return data is List ? data : (data['pills'] ?? []);
  }

  Future<Map<String, dynamic>> createPill(Map<String, dynamic> pill) async {
    final res = await _post('/pills', pill);
    pillHistoryChanged.add(null);
    return res;
  }

  Future<Map<String, dynamic>> updatePill(
    String id,
    Map<String, dynamic> pill,
  ) async {
    final res = await _put('/pills/$id', pill);
    pillHistoryChanged.add(null);
    return res;
  }

  Future<void> deletePill(String id) async {
    await _delete('/pills/$id');
    pillHistoryChanged.add(null);
  }

  Future<void> markPillTaken(String id) async {
    await _post('/pills/$id/taken');
    pillHistoryChanged.add(null);
  }

  Future<void> markPillMissed(String id) async {
    await _post('/pills/$id/missed');
    pillHistoryChanged.add(null);
  }

  Future<List<dynamic>> getPillHistory(String id) async {
    final data = await _get('/pills/$id/history');
    return data is List ? data : (data['history'] ?? []);
  }

  Future<Map<String, dynamic>> clearPillHistory() async {
    final res = await _delete('/pills/history');
    pillHistoryChanged.add(null);
    return res;
  }

  Future<Map<String, dynamic>> saveAllergenProfile(
    List<String> allergens,
  ) async {
    return await _post('/allergens/profile', {'allergens': allergens});
  }

  Future<Map<String, dynamic>> getMyAllergens() async {
    return await _get('/allergens/profile');
  }

  Future<Map<String, dynamic>> scanLabel(String labelText) async {
    final result = await _post('/allergens/scan', {'text': labelText});
    allergenHistoryChanged.add(null);
    return result;
  }

  Future<Map<String, dynamic>> scanImage(File imageFile) async {
    final token = await _auth.currentUser?.getIdToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/allergens/scan-image'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final res = await request.send().timeout(const Duration(seconds: 30));
    final responseData = await http.Response.fromStream(res);

    if (responseData.statusCode >= 200 && responseData.statusCode < 300) {
      allergenHistoryChanged.add(null);
      return responseData.body.isNotEmpty
          ? jsonDecode(responseData.body)
          : null;
    }
    throw ApiException(responseData.statusCode, responseData.body);
  }

  Future<List<dynamic>> getScanHistory() async {
    final data = await _get('/allergens/history');
    return data is List ? data : (data['history'] ?? []);
  }

  Future<Map<String, dynamic>> clearScanHistory() async {
    final result = await _delete('/allergens/history');
    allergenHistoryChanged.add(null);
    return result;
  }

  Future<Map<String, dynamic>> clearAllergenProfile() async {
    return await _delete('/allergens/profile');
  }

  Future<List<dynamic>> getExercises({
    String? bodyPart,
    String? difficulty,
    String? category,
    String? search,
  }) async {
    final params = <String, String>{};
    if (bodyPart != null) params['bodyPart'] = bodyPart;
    if (difficulty != null) params['difficulty'] = difficulty;
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;

    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : '';
    final data = await _get('/exercises$query');
    return data is List ? data : (data['data'] ?? []);
  }

  Future<List<dynamic>> getFavoriteExercises() async {
    final data = await _get('/exercises/favorites');
    return data is List ? data : (data['data'] ?? []);
  }

  Future<List<dynamic>> toggleFavoriteExercise(String id) async {
    final data = await _post('/exercises/$id/favorite');
    return data is List ? data : (data['data'] ?? []);
  }

  Future<Map<String, dynamic>> getExerciseById(String id) async {
    return await _get('/exercises/$id');
  }

  Future<Map<String, dynamic>> createExercise(
    Map<String, dynamic> exercise,
  ) async {
    return await _post('/exercises', exercise);
  }

  Future<Map<String, dynamic>> logExercise(Map<String, dynamic> log) async {
    return await _post('/exercises/logs', log);
  }

  Future<List<dynamic>> getExerciseHistory() async {
    final data = await _get('/exercises/history');
    return data is List ? data : (data['data'] ?? []);
  }

  Future<Map<String, dynamic>> createWorkout(
    Map<String, dynamic> workout,
  ) async {
    return await _post('/workouts', workout);
  }

  Future<List<dynamic>> getWorkouts() async {
    final data = await _get('/workouts');
    return data is List ? data : (data['data'] ?? []);
  }

  Future<Map<String, dynamic>> updateExercise(
    String id,
    Map<String, dynamic> exercise,
  ) async {
    final data = await _put('/exercises/$id', exercise);
    return data is Map<String, dynamic> ? (data['data'] ?? data) : data;
  }

  Future<void> deleteExercise(String id) async {
    await _delete('/exercises/$id');
  }

  Future<Map<String, dynamic>> updateWorkout(
    String id,
    Map<String, dynamic> workout,
  ) async {
    final data = await _put('/workouts/$id', workout);
    return data is Map<String, dynamic> ? (data['data'] ?? data) : data;
  }

  Future<void> deleteWorkout(String id) async {
    await _delete('/workouts/$id');
  }

  Future<Map<String, dynamic>> getWorkoutById(String id) async {
    final data = await _get('/workouts/$id');
    return data is Map<String, dynamic> ? (data['data'] ?? data) : data;
  }

  Future<void> sendNotification(Map<String, dynamic> payload) async {
    await _post('/notifications/send', payload);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
