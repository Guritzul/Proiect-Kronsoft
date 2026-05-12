import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'exercise_detail_screen.dart';

/// Exercises grid screen with filters for body part and difficulty.
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final _api = ApiService();
  List<dynamic> _exercises = [];
  bool _loading = true;

  String? _selectedBodyPart;
  String? _selectedDifficulty;

  final List<String> _bodyParts = [
    'All', 'Forearm', 'Biceps', 'Triceps', 'Back', 'Legs', 'Shoulders', 'Chest', 'Core', 'Neck', 'Cardio',
  ];
  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getExercises(
        bodyPart: _selectedBodyPart?.toLowerCase(),
        difficulty: _selectedDifficulty,
      );
      if (mounted) setState(() { _exercises = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text('Recovery Exercises')),
      body: Column(
        children: [
          // ── Filters ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Body Part', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _bodyParts.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final bp = _bodyParts[i];
                      final selected = (_selectedBodyPart == null && bp == 'All') ||
                          _selectedBodyPart == bp;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedBodyPart = bp == 'All' ? null : bp);
                          _loadExercises();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentColor.withValues(alpha: 0.2)
                                : AppColors.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accentColor
                                  : AppColors.cardColor,
                            ),
                          ),
                          child: Text(
                            bp,
                            style: TextStyle(
                              color: selected ? AppColors.accentColor : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Difficulty', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _difficulties.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final d = _difficulties[i];
                      final selected = (_selectedDifficulty == null && d == 'All') ||
                          _selectedDifficulty?.toLowerCase() == d.toLowerCase();
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDifficulty = d == 'All' ? null : d.toLowerCase());
                          _loadExercises();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentColor.withValues(alpha: 0.2)
                                : AppColors.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accentColor
                                  : AppColors.cardColor,
                            ),
                          ),
                          child: Text(
                            d,
                            style: TextStyle(
                              color: selected ? AppColors.accentColor : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Grid ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentColor))
                : _exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 10),
                            const Text('No exercises found', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            const Text('Try adjusting filters', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.accentColor,
                        backgroundColor: AppColors.surfaceColor,
                        onRefresh: _loadExercises,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: _exercises.length,
                          itemBuilder: (_, i) => _ExerciseCard(
                            exercise: _exercises[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseDetailScreen(exercise: _exercises[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;

  const _ExerciseCard({required this.exercise, required this.onTap});

  IconData get _bodyPartIcon {
    switch ((exercise['bodyPart'] ?? '').toString().toLowerCase()) {
      case 'forearm':
      case 'biceps':
      case 'triceps':
        return Icons.front_hand;
      case 'legs':
        return Icons.directions_walk;
      case 'back':
        return Icons.airline_seat_flat;
      case 'chest':
        return Icons.shield;
      case 'shoulders':
        return Icons.accessibility_new;
      case 'core':
        return Icons.circle;
      case 'neck':
        return Icons.face;
      case 'cardio':
        return Icons.favorite_border;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = exercise['name'] ?? 'Exercise';
    final bodyPart = exercise['bodyPart'] ?? '';
    final difficulty = exercise['difficulty'] ?? 'medium';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accentColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with icon
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentColor.withValues(alpha: 0.08),
                      AppColors.surfaceColor,
                    ],
                  ),
                ),
                child: Icon(_bodyPartIcon, size: 40, color: AppColors.accentColor.withValues(alpha: 0.5)),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (bodyPart.isNotEmpty)
                          Text(
                            bodyPart,
                            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                          ),
                        DifficultyBadge(difficulty: difficulty),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
