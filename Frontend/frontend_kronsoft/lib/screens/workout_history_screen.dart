import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  List<dynamic> _workoutHistory = [];
  List<dynamic> _singleExerciseHistory = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getExerciseHistory();
      if (mounted) {
        setState(() {
          _splitHistory(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
  }

  void _splitHistory(List<dynamic> rawHistory) {
    final List<Map<String, dynamic>> workoutsTemp = [];
    final List<Map<String, dynamic>> singlesTemp = [];

    for (final group in rawHistory) {
      final date = group['date'];
      final logs = group['logs'] as List<dynamic>? ?? [];

      // Filter logs that belong to workouts
      final workoutLogs = logs
          .where((log) => log['workoutName'] != null)
          .toList();
      if (workoutLogs.isNotEmpty) {
        workoutsTemp.add({'date': date, 'logs': workoutLogs});
      }

      // Filter logs that do NOT belong to workouts
      final singleLogs = logs
          .where((log) => log['workoutName'] == null)
          .toList();
      if (singleLogs.isNotEmpty) {
        singlesTemp.add({'date': date, 'logs': singleLogs});
      }
    }

    _workoutHistory = workoutsTemp;
    _singleExerciseHistory = singlesTemp;
  }

  IconData _getBodyPartIcon(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'forearm':
      case 'biceps':
      case 'triceps':
        return Icons.fitness_center_rounded;
      case 'legs':
        return Icons.directions_run_rounded;
      case 'back':
        return Icons.accessibility_new_rounded;
      case 'chest':
        return Icons.shield_rounded;
      case 'shoulders':
        return Icons.sports_gymnastics_rounded;
      case 'core':
        return Icons.circle_outlined;
      case 'neck':
        return Icons.face_retouching_natural_rounded;
      case 'cardio':
        return Icons.favorite_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  Widget _buildCapsuleTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: context.appColors.accentColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildCapsuleTabItem(0, 'Workout Routines')),
          Expanded(child: _buildCapsuleTabItem(1, 'Single Exercises')),
        ],
      ),
    );
  }

  Widget _buildCapsuleTabItem(int index, String label) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.accentColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.appColors.accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : context.appColors.textSecondary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCapsuleTabBar(),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.appColors.accentColor,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _workoutHistory.isEmpty
                          ? _buildEmptyState(
                              'No routine history yet',
                              'Complete a workout routine to see it here!',
                            )
                          : _buildWorkoutRoutineList(),
                      _singleExerciseHistory.isEmpty
                          ? _buildEmptyState(
                              'No single exercise history yet',
                              'Log an individual exercise to see it here!',
                            )
                          : _buildSingleExerciseList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: context.appColors.textHint.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appColors.textHint, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutRoutineList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _workoutHistory.length,
      separatorBuilder: (_, _) => const SizedBox(height: 24),
      itemBuilder: (_, index) {
        final group = _workoutHistory[index];
        final dateStr = group['date'] ?? '';
        final logs = group['logs'] as List<dynamic>;

        final Map<String, List<dynamic>> workoutSessions = {};
        for (final log in logs) {
          final workoutName = log['workoutName'] ?? 'Workout Routine';
          if (!workoutSessions.containsKey(workoutName)) {
            workoutSessions[workoutName] = [];
          }
          workoutSessions[workoutName]!.add(log);
        }

        String formattedDate = dateStr;
        try {
          final parsedDate = DateTime.parse(dateStr);
          formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
        } catch (_) {}

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(formattedDate),
            const SizedBox(height: 12),
            ...workoutSessions.entries.map((entry) {
              final workoutName = entry.key;
              final sessionLogs = entry.value;

              String completedTime = '';
              try {
                if (sessionLogs.first['createdAt'] != null) {
                  completedTime = DateFormat(
                    'HH:mm',
                  ).format(DateTime.parse(sessionLogs.first['createdAt']));
                }
              } catch (_) {}

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 24,
                  borderColor: context.appColors.accentColor.withValues(
                    alpha: 0.12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              workoutName,
                              style: TextStyle(
                                color: context.appColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (completedTime.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: context.appColors.accentColor.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: context.appColors.accentColor
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 11,
                                    color: context.appColors.accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    completedTime,
                                    style: TextStyle(
                                      color: context.appColors.accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${sessionLogs.length} exercises completed successfully',
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(height: 24),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessionLogs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (ctx, i) {
                          final log = sessionLogs[i];
                          final ex = log['exerciseId'] ?? {};
                          final exName = ex['name'] ?? 'Deleted Exercise';
                          final sets = log['sets'] ?? 0;
                          final reps = log['repetitions'] ?? 0;
                          final duration = log['durationMinutes'] ?? 0;
                          final notes = log['notes'] ?? '';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 16,
                                    color: context.appColors.accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      exName,
                                      style: TextStyle(
                                        color: context.appColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Row(
                                  children: [
                                    _StatIconTile(
                                      label: 'Sets',
                                      value: '$sets',
                                      icon: Icons.layers_outlined,
                                    ),
                                    const SizedBox(width: 18),
                                    _StatIconTile(
                                      label: 'Reps',
                                      value: '$reps',
                                      icon: Icons.repeat,
                                    ),
                                    if (duration > 0) ...[
                                      const SizedBox(width: 18),
                                      _StatIconTile(
                                        label: 'Time',
                                        value: '${duration}m',
                                        icon: Icons.timer_outlined,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (notes.isNotEmpty &&
                                  !notes.startsWith('Completed via')) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.appColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.notes_rounded,
                                          size: 12,
                                          color:
                                              context.appColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            notes,
                                            style: TextStyle(
                                              color: context
                                                  .appColors
                                                  .textSecondary,
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSingleExerciseList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _singleExerciseHistory.length,
      separatorBuilder: (_, _) => const SizedBox(height: 24),
      itemBuilder: (_, index) {
        final group = _singleExerciseHistory[index];
        final dateStr = group['date'] ?? '';
        final logs = group['logs'] as List<dynamic>;

        String formattedDate = dateStr;
        try {
          final parsedDate = DateTime.parse(dateStr);
          formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
        } catch (_) {}

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(formattedDate),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final log = logs[i];
                final ex = log['exerciseId'] ?? {};
                final exName = ex['name'] ?? 'Deleted Exercise';
                final bodyPart = ex['bodyPart'] ?? 'Custom';
                final sets = log['sets'] ?? 0;
                final reps = log['repetitions'] ?? 0;
                final duration = log['durationMinutes'] ?? 0;
                final notes = log['notes'] ?? '';

                String logTime = '';
                try {
                  if (log['createdAt'] != null) {
                    logTime = DateFormat(
                      'HH:mm',
                    ).format(DateTime.parse(log['createdAt']));
                  }
                } catch (_) {}

                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  borderColor: context.appColors.accentColor.withValues(
                    alpha: 0.12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.appColors.accentColor.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.appColors.accentColor.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Icon(
                          _getBodyPartIcon(bodyPart),
                          size: 20,
                          color: context.appColors.accentColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    exName,
                                    style: TextStyle(
                                      color: context.appColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (logTime.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 11,
                                        color: context.appColors.textHint,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        logTime,
                                        style: TextStyle(
                                          color: context.appColors.textHint,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  bodyPart.toUpperCase(),
                                  style: TextStyle(
                                    color: context.appColors.accentColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: context.appColors.textHint
                                        .withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$sets sets x $reps reps',
                                  style: TextStyle(
                                    color: context.appColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (duration > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: context.appColors.textHint
                                          .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 11,
                                    color: context.appColors.textHint,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${duration}m',
                                    style: TextStyle(
                                      color: context.appColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (notes.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      size: 12,
                                      color: context.appColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        notes,
                                        style: TextStyle(
                                          color:
                                              context.appColors.textSecondary,
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String formattedDate) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.appColors.accentColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 12,
              color: context.appColors.accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate.toUpperCase(),
            style: TextStyle(
              color: context.appColors.accentColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatIconTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatIconTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: context.appColors.textHint),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
