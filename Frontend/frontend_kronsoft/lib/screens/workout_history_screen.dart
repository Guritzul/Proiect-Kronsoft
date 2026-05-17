import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> with SingleTickerProviderStateMixin {
  final _api = ApiService();
  List<dynamic> _workoutHistory = [];
  List<dynamic> _singleExerciseHistory = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final workoutLogs = logs.where((log) => log['workoutName'] != null).toList();
      if (workoutLogs.isNotEmpty) {
        workoutsTemp.add({
          'date': date,
          'logs': workoutLogs,
        });
      }

      // Filter logs that do NOT belong to workouts
      final singleLogs = logs.where((log) => log['workoutName'] == null).toList();
      if (singleLogs.isNotEmpty) {
        singlesTemp.add({
          'date': date,
          'logs': singleLogs,
        });
      }
    }

    _workoutHistory = workoutsTemp;
    _singleExerciseHistory = singlesTemp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.appColors.accentColor,
          labelColor: context.appColors.accentColor,
          unselectedLabelColor: context.appColors.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.fitness_center_rounded, size: 20),
              text: 'Workout Routines',
            ),
            Tab(
              icon: Icon(Icons.directions_run_rounded, size: 20),
              text: 'Single Exercises',
            ),
          ],
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accentColor,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _workoutHistory.isEmpty
                    ? _buildEmptyState('No routine history yet', 'Complete a workout routine to see it here!')
                    : _buildWorkoutRoutineList(),
                _singleExerciseHistory.isEmpty
                    ? _buildEmptyState('No single exercise history yet', 'Log an individual exercise to see it here!')
                    : _buildSingleExerciseList(),
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

        // Group logs of the same workout completed on this day
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

              // Find the latest completed time in this session
              String completedTime = '';
              try {
                if (sessionLogs.first['createdAt'] != null) {
                  completedTime = DateFormat('HH:mm').format(
                    DateTime.parse(sessionLogs.first['createdAt']),
                  );
                }
              } catch (_) {}

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.appColors.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                completedTime,
                                style: TextStyle(
                                  color: context.appColors.accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                                    _StatIconTile(label: 'Sets', value: '$sets', icon: Icons.layers_outlined),
                                    const SizedBox(width: 18),
                                    _StatIconTile(label: 'Reps', value: '$reps', icon: Icons.repeat),
                                    if (duration > 0) ...[
                                      const SizedBox(width: 18),
                                      _StatIconTile(label: 'Time', value: '${duration}m', icon: Icons.timer_outlined),
                                    ],
                                  ],
                                ),
                              ),
                              if (notes.isNotEmpty && !notes.startsWith('Completed via')) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: context.appColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.notes_rounded, size: 12, color: context.appColors.textSecondary),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            notes,
                                            style: TextStyle(
                                              color: context.appColors.textSecondary,
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
                final sets = log['sets'] ?? 0;
                final reps = log['repetitions'] ?? 0;
                final duration = log['durationMinutes'] ?? 0;
                final notes = log['notes'] ?? '';

                String logTime = '';
                try {
                  if (log['createdAt'] != null) {
                    logTime = DateFormat('HH:mm').format(DateTime.parse(log['createdAt']));
                  }
                } catch (_) {}

                return GlassCard(
                  padding: const EdgeInsets.all(16),
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (logTime.isNotEmpty)
                            Text(
                              logTime,
                              style: TextStyle(
                                color: context.appColors.textHint,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatTile(label: 'Sets', value: '$sets', icon: Icons.layers_outlined),
                          const SizedBox(width: 24),
                          _StatTile(label: 'Reps', value: '$reps', icon: Icons.repeat),
                          if (duration > 0) ...[
                            const SizedBox(width: 24),
                            _StatTile(label: 'Time', value: '${duration}m', icon: Icons.timer_outlined),
                          ],
                        ],
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: context.appColors.surfaceColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.note_alt_outlined, size: 14, color: context.appColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  notes,
                                  style: TextStyle(
                                    color: context.appColors.textSecondary,
                                    fontSize: 12,
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
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: context.appColors.accentColor,
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate,
            style: TextStyle(
              color: context.appColors.accentColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: context.appColors.accentColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: context.appColors.textHint, fontSize: 10),
            ),
          ],
        ),
      ],
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
        Icon(
          icon,
          size: 12,
          color: context.appColors.textHint,
        ),
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
