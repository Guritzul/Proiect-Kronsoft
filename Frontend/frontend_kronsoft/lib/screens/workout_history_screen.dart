import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/workout_service.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final _workoutService = WorkoutService();
  List<WorkoutSession> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _workoutService.getHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear History?'),
                    content: const Text('This will delete all saved workouts.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _workoutService.clearHistory();
                  _loadHistory();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: context.appColors.accentColor))
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: context.appColors.textHint.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(color: context.appColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first exercise to see it here!',
            style: TextStyle(color: context.appColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final s = _history[i];
        final dateStr = DateFormat('MMM dd, yyyy • HH:mm').format(s.date);
        
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
                      s.exerciseName,
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: context.appColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatTile(
                    label: 'Reps',
                    value: '${s.reps}',
                    icon: Icons.repeat,
                  ),
                  const SizedBox(width: 24),
                  _StatTile(
                    label: 'Sets',
                    value: '${s.sets}',
                    icon: Icons.layers_outlined,
                  ),
                  const SizedBox(width: 24),
                  _StatTile(
                    label: 'Time',
                    value: '${s.durationSeconds}s',
                    icon: Icons.timer_outlined,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.appColors.accentColor.withValues(alpha: 0.7)),
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
              style: TextStyle(
                color: context.appColors.textHint,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
