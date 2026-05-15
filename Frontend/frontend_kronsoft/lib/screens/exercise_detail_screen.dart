import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int _seconds = 0;
  bool _timerRunning = false;
  Timer? _timer;

  int _reps = 0;
  int _sets = 0;

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
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.appColors.accentColor.withValues(alpha: 0.15),
                  context.appColors.surfaceColor,
                ],
              ),
              border: Border.all(
                color: context.appColors.accentColor.withValues(alpha: 0.12),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.fitness_center,
                size: 64,
                color: context.appColors.accentColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (bodyPart.isNotEmpty)
                _MetaChip(icon: Icons.accessibility_new, label: bodyPart),
              _MetaChip(icon: Icons.speed, label: difficulty),
              if (category.isNotEmpty)
                _MetaChip(icon: Icons.category, label: category),
            ],
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'Description'),
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

          const SectionHeader(title: 'Timer'),
          GlassCard(
            child: Column(
              children: [
                Text(
                  _formattedTime,
                  style: TextStyle(
                    color: _timerRunning
                        ? context.appColors.accentColor
                        : context.appColors.textPrimary,
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _toggleTimer,
                          icon: Icon(
                            _timerRunning ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(_timerRunning ? 'Pause' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _timerRunning
                                ? context.appColors.warningColor
                                : context.appColors.accentColor,
                            foregroundColor: context.appColors.bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.replay, size: 20),
                        label: Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appColors.textSecondary,
                          side: BorderSide(
                            color: context.appColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const SectionHeader(title: 'Tracking'),
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
              const SizedBox(width: 14),
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
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.appColors.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.appColors.accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              color: context.appColors.accentColor,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: filled ? context.appColors.accentColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: filled
                ? context.appColors.accentColor
                : context.appColors.textSecondary.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled
              ? context.appColors.bgColor
              : context.appColors.textSecondary,
        ),
      ),
    );
  }
}
