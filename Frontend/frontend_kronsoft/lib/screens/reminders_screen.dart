import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reminders screen – shows pill and exercise reminder cards.
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Pill Reminders ──
          const SectionHeader(title: 'Pill Reminders'),
          _ReminderCard(
            icon: Icons.medication_rounded,
            title: 'Morning Medications',
            subtitle: 'Take your morning pills at 8:00 AM',
            color: AppColors.accentColor,
            time: '08:00 AM',
          ),
          const SizedBox(height: 10),
          _ReminderCard(
            icon: Icons.medication_rounded,
            title: 'Evening Medications',
            subtitle: 'Don\'t forget your evening dose',
            color: const Color(0xFF7C4DFF),
            time: '08:00 PM',
          ),
          const SizedBox(height: 10),
          _ReminderCard(
            icon: Icons.medication_liquid,
            title: 'Vitamins',
            subtitle: 'Take your daily vitamins with food',
            color: AppColors.warningColor,
            time: '12:30 PM',
          ),
          const SizedBox(height: 28),

          // ── Exercise Reminders ──
          const SectionHeader(title: 'Exercise Reminders'),
          _ReminderCard(
            icon: Icons.fitness_center_rounded,
            title: 'Morning Stretch',
            subtitle: '15 minutes of stretching to start your day',
            color: AppColors.successColor,
            time: '07:00 AM',
          ),
          const SizedBox(height: 10),
          _ReminderCard(
            icon: Icons.directions_walk_rounded,
            title: 'Afternoon Walk',
            subtitle: '30 minutes of light walking',
            color: const Color(0xFFFF6E40),
            time: '04:00 PM',
          ),
          const SizedBox(height: 10),
          _ReminderCard(
            icon: Icons.self_improvement,
            title: 'Recovery Session',
            subtitle: 'Gentle recovery exercises for 20 minutes',
            color: const Color(0xFF26C6DA),
            time: '06:30 PM',
          ),
          const SizedBox(height: 28),

          // ── Tip ──
          GlassCard(
            borderColor: AppColors.accentColor.withValues(alpha: 0.2),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tips_and_updates, color: AppColors.accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Reminders are synced with your pill schedule and exercise plan. Stay consistent for best results!',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  const _ReminderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
