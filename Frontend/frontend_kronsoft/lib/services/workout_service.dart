import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSession {
  final String exerciseId;
  final String exerciseName;
  final int reps;
  final int sets;
  final int durationSeconds;
  final DateTime date;

  WorkoutSession({
    required this.exerciseId,
    required this.exerciseName,
    required this.reps,
    required this.sets,
    required this.durationSeconds,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'reps': reps,
    'sets': sets,
    'durationSeconds': durationSeconds,
    'date': date.toIso8601String(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    exerciseId: json['exerciseId'],
    exerciseName: json['exerciseName'],
    reps: json['reps'],
    sets: json['sets'],
    durationSeconds: json['durationSeconds'],
    date: DateTime.parse(json['date']),
  );
}

class WorkoutService {
  static const String _key = 'workout_history';

  Future<void> saveSession(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, session);
    final jsonList = history.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<List<WorkoutSession>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => WorkoutSession.fromJson(jsonDecode(s))).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
