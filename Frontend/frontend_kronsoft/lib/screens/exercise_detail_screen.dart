import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/workout_service.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final _api = ApiService();
  final _workoutService = WorkoutService();

  int _seconds = 0;
  bool _timerRunning = false;
  Timer? _timer;

  int _reps = 0;
  int _sets = 0;
  bool _isFavorite = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final favs = await _api.getFavoriteExercises();
      if (mounted) {
        setState(() {
          _isFavorite = favs.any((f) => f['_id'] == widget.exercise['_id']);
        });
      }
    } catch (_) {}
  }

  void _toggleTimer() {
    if (_timerRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    }
    setState(() => _timerRunning = !_timerRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _timerRunning = false;
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    try {
      await _api.toggleFavoriteExercise(widget.exercise['_id']);
    } catch (_) {
      if (mounted) setState(() => _isFavorite = !_isFavorite);
    }
  }

  Future<void> _saveWorkout() async {
    if (_reps == 0 && _sets == 0 && _seconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please perform some reps or sets first')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _workoutService.saveSession(WorkoutSession(
        exerciseId: widget.exercise['_id'],
        exerciseName: widget.exercise['name'],
        reps: _reps,
        sets: _sets,
        durationSeconds: _seconds,
        date: DateTime.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully! ✓')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving workout: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final name = e['name'] ?? 'Exercise';
    final bodyPart = e['bodyPart'] ?? '';
    final difficulty = e['difficulty'] ?? 'medium';
    final description = e['description'] ?? 'No description available.';
    final category = e['category'] ?? '';

    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? context.appColors.dangerColor : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 24),
          _buildMetaRow(bodyPart, difficulty, category),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Overview'),
          GlassCard(
            child: Text(
              description,
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildTimerSection(),
          const SizedBox(height: 28),
          _buildTrackingSection(),
          const SizedBox(height: 32),
          AccentButton(
            label: 'Complete Workout',
            icon: Icons.check_circle_outline,
            isLoading: _saving,
            onPressed: _saveWorkout,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.appColors.accentColor.withValues(alpha: 0.2),
            context.appColors.surfaceColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 72,
          color: context.appColors.accentColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String bodyPart, String difficulty, String category) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        if (bodyPart.isNotEmpty)
          _MetaChip(icon: Icons.accessibility_new, label: bodyPart),
        _MetaChip(icon: Icons.speed, label: difficulty),
        if (category.isNotEmpty)
          _MetaChip(icon: Icons.category, label: category),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Workout Timer'),
        GlassCard(
          child: Column(
            children: [
              Text(
                _formattedTime,
                style: TextStyle(
                  color: _timerRunning
                      ? context.appColors.accentColor
                      : context.appColors.textPrimary,
                  fontSize: 56,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(_timerRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_timerRunning ? 'Pause' : 'Start Timer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _timerRunning
                            ? context.appColors.warningColor
                            : context.appColors.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.replay),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Log Activity'),
        Row(
          children: [
            Expanded(
              child: _CounterCard(
                label: 'Reps',
                value: _reps,
                onIncrement: () => setState(() => _reps++),
                onDecrement: () => setState(() {
                  if (_reps > 0) _reps--;
                }),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CounterCard(
                label: 'Sets',
                value: _sets,
                onIncrement: () => setState(() => _sets++),
                onDecrement: () => setState(() {
                  if (_sets > 0) _sets--;
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.appColors.accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.appColors.accentColor),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CounterCard({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: TextStyle(
              color: context.appColors.accentColor,
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundButton(icon: Icons.remove, onTap: onDecrement),
              const SizedBox(width: 16),
              _RoundButton(icon: Icons.add, onTap: onIncrement, filled: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: filled ? context.appColors.accentColor : context.appColors.surfaceColor,
          shape: BoxShape.circle,
          boxShadow: filled ? [
            BoxShadow(
              color: context.appColors.accentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? Colors.white : context.appColors.textPrimary,
        ),
      ),
    );
  }
}
