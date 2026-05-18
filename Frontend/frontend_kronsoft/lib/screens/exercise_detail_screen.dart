import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/workout_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final _api = ApiService();
  final _workoutService = WorkoutService();

  late Map<String, dynamic> _exerciseData;

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
    _exerciseData = Map<String, dynamic>.from(widget.exercise);
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final favs = await _api.getFavoriteExercises();
      if (mounted) {
        setState(() {
          _isFavorite = favs.any((f) => f['_id'] == _exerciseData['_id']);
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
      await _api.toggleFavoriteExercise(_exerciseData['_id']);
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
      // Save locally (offline fallback)
      try {
        await _workoutService.saveSession(
          WorkoutSession(
            exerciseId: _exerciseData['_id'],
            exerciseName: _exerciseData['name'],
            reps: _reps,
            sets: _sets,
            durationSeconds: _seconds,
            date: DateTime.now(),
          ),
        );
      } catch (_) {}

      // Save to backend database
      await _api.logExercise({
        'exerciseId': _exerciseData['_id'],
        'sets': _sets > 0 ? _sets : _exerciseData['sets'] ?? 3,
        'repetitions': _reps > 0 ? _reps : _exerciseData['repetitions'] ?? 15,
        'durationMinutes': _seconds > 0
            ? (_seconds / 60).ceil()
            : _exerciseData['durationMinutes'] ?? 5,
        'notes': 'Logged via timer session',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully! ✓')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving workout: $e')));
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

  void _showEditExerciseDialog() {
    final formKey = GlobalKey<FormState>();
    String name = _exerciseData['name'] ?? '';
    String description = _exerciseData['description'] ?? '';
    String bodyPart = _exerciseData['bodyPart'] ?? 'chest';
    String difficulty = _exerciseData['difficulty'] ?? 'medium';
    int sets = _exerciseData['sets'] ?? 3;
    int reps = _exerciseData['repetitions'] ?? 15;
    int duration = _exerciseData['durationMinutes'] ?? 5;
    String category = _exerciseData['category'] ?? 'Strength';
    String mediaUrl = _exerciseData['mediaUrl'] ?? '';

    final List<String> bodyParts = [
      'Forearm',
      'Biceps',
      'Triceps',
      'Back',
      'Legs',
      'Shoulders',
      'Chest',
      'Core',
      'Neck',
      'Cardio',
    ];
    final List<String> difficulties = ['Easy', 'Medium', 'Hard'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Custom Exercise'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: name,
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name*',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        onSaved: (v) => name = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: description,
                        decoration: const InputDecoration(
                          labelText: 'Description*',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 2,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        onSaved: (v) => description = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: bodyPart.toLowerCase(),
                        decoration: const InputDecoration(
                          labelText: 'Body Part',
                          prefixIcon: Icon(Icons.accessibility_new_rounded),
                        ),
                        items: bodyParts
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.toLowerCase(),
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => bodyPart = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: difficulty.toLowerCase(),
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          prefixIcon: Icon(Icons.speed_rounded),
                        ),
                        items: difficulties
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.toLowerCase(),
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => difficulty = v!),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: '$sets',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Sets',
                              ),
                              validator: (v) => int.tryParse(v ?? '') == null
                                  ? 'Invalid'
                                  : null,
                              onSaved: (v) => sets = int.parse(v!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: '$reps',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                              ),
                              validator: (v) => int.tryParse(v ?? '') == null
                                  ? 'Invalid'
                                  : null,
                              onSaved: (v) => reps = int.parse(v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: '$duration',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (Minutes)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        validator: (v) =>
                            int.tryParse(v ?? '') == null ? 'Invalid' : null,
                        onSaved: (v) => duration = int.parse(v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        onSaved: (v) => category = v?.trim() ?? 'Strength',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: mediaUrl,
                        decoration: const InputDecoration(
                          labelText: 'Video Explanation Link',
                          prefixIcon: Icon(Icons.video_library_outlined),
                          hintText: 'https://youtube.com/...',
                        ),
                        onSaved: (v) => mediaUrl = v?.trim() ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final colors = context.appColors;

                    try {
                      final updated = await _api
                          .updateExercise(_exerciseData['_id'], {
                            'name': name,
                            'description': description,
                            'bodyPart': bodyPart,
                            'difficulty': difficulty,
                            'sets': sets,
                            'repetitions': reps,
                            'durationMinutes': duration,
                            'category': category,
                            'mediaUrl': mediaUrl,
                          });
                      if (!mounted) return;
                      navigator.pop();
                      setState(() {
                        _exerciseData = updated;
                      });
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Exercise "$name" updated successfully! ✓',
                          ),
                          backgroundColor: colors.successColor,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to update exercise: $e'),
                          backgroundColor: colors.dangerColor,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteExercise() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exercise?'),
        content: const Text(
          'Are you sure you want to delete this custom exercise? It will be removed from your catalog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.dangerColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final colors = context.appColors;
      try {
        await _api.deleteExercise(_exerciseData['_id']);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Custom exercise deleted successfully'),
            backgroundColor: colors.successColor,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete exercise: $e'),
            backgroundColor: colors.dangerColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = _exerciseData;
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
          if (_exerciseData['createdBy'] != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit Custom Exercise',
              onPressed: _showEditExerciseDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete Custom Exercise',
              onPressed: _deleteExercise,
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 24),
          _buildMetaRow(bodyPart, difficulty, category),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Overview'),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderColor: context.appColors.accentColor.withValues(alpha: 0.1),
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
    final mediaUrl = _exerciseData['mediaUrl'] as String?;
    final hasVideo = mediaUrl != null && mediaUrl.isNotEmpty;
    final partName = (_exerciseData['bodyPart'] ?? '').toString().toLowerCase();

    IconData partIcon;
    switch (partName) {
      case 'forearm':
      case 'biceps':
      case 'triceps':
        partIcon = Icons.fitness_center_rounded;
        break;
      case 'legs':
        partIcon = Icons.directions_run_rounded;
        break;
      case 'back':
        partIcon = Icons.accessibility_new_rounded;
        break;
      case 'chest':
        partIcon = Icons.shield_rounded;
        break;
      case 'shoulders':
        partIcon = Icons.sports_gymnastics_rounded;
        break;
      case 'core':
        partIcon = Icons.circle_outlined;
        break;
      case 'neck':
        partIcon = Icons.face_retouching_natural_rounded;
        break;
      case 'cardio':
        partIcon = Icons.favorite_rounded;
        break;
      default:
        partIcon = Icons.fitness_center_rounded;
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.appColors.accentColor.withValues(alpha: 0.15),
                context.appColors.cardColor,
              ],
            ),
            border: Border.all(
              color: context.appColors.accentColor.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: context.appColors.accentGlow.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.appColors.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.appColors.accentColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                partIcon,
                size: 56,
                color: context.appColors.accentColor,
              ),
            ),
          ),
        ),
        if (hasVideo)
          Positioned(
            bottom: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.redAccent.withValues(alpha: 0.9),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      String normalizedUrl = mediaUrl.trim();
                      if (!normalizedUrl.startsWith('http://') &&
                          !normalizedUrl.startsWith('https://')) {
                        normalizedUrl = 'https://$normalizedUrl';
                      }
                      final uri = Uri.parse(normalizedUrl);
                      try {
                        final launched = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!launched) {
                          // Try platformDefault if externalApplication failed
                          final launchedFallback = await launchUrl(
                            uri,
                            mode: LaunchMode.platformDefault,
                          );
                          if (!launchedFallback && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open video link'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open video link: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Video Guide',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetaRow(String bodyPart, String difficulty, String category) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        if (bodyPart.isNotEmpty)
          _MetaChip(
            icon: Icons.accessibility_new_rounded,
            label: bodyPart,
            type: 'bodyPart',
          ),
        _MetaChip(
          icon: Icons.speed_rounded,
          label: difficulty,
          type: 'difficulty',
        ),
        if (category.isNotEmpty)
          _MetaChip(
            icon: Icons.category_rounded,
            label: category,
            type: 'category',
          ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Workout Timer'),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderColor: context.appColors.accentColor.withValues(
            alpha: _timerRunning ? 0.25 : 0.1,
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _timerRunning
                        ? context.appColors.accentColor.withValues(alpha: 0.3)
                        : context.appColors.accentColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  _formattedTime,
                  style: TextStyle(
                    color: _timerRunning
                        ? context.appColors.accentColor
                        : context.appColors.textPrimary,
                    fontSize: 54,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: _timerRunning
                            ? context.appColors.warningColor
                            : context.appColors.accentColor,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggleTimer,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _timerRunning
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _timerRunning
                                        ? 'Pause Timer'
                                        : 'Start Timer',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipOval(
                    child: Container(
                      color: context.appColors.surfaceColor,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _resetTimer,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.replay_rounded,
                              color: context.appColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
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
  final String type;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.type,
  });

  Color _getChipColor(BuildContext context) {
    if (type == 'difficulty') {
      switch (label.toLowerCase()) {
        case 'easy':
          return context.appColors.successColor;
        case 'medium':
          return context.appColors.warningColor;
        case 'hard':
          return context.appColors.dangerColor;
      }
    }
    return context.appColors.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _getChipColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type == 'difficulty')
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            )
          else
            Icon(icon, size: 14, color: activeColor),
          if (type != 'difficulty') const SizedBox(width: 6),
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
      borderColor: context.appColors.accentColor.withValues(alpha: 0.1),
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
              _RoundButton(icon: Icons.remove_rounded, onTap: onDecrement),
              const SizedBox(width: 16),
              _RoundButton(
                icon: Icons.add_rounded,
                onTap: onIncrement,
                filled: true,
              ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: filled
              ? context.appColors.accentColor
              : context.appColors.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.appColors.accentColor.withValues(
              alpha: filled ? 0.0 : 0.1,
            ),
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: context.appColors.accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
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
