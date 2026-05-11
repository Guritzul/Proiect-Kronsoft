import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Notification settings – pill reminders, exercise reminders, scan alerts, quiet hours.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification toggles
  bool _pillReminders = true;
  bool _missedPillAlerts = true;
  bool _exerciseReminders = true;
  bool _scanAlerts = true;
  bool _dailySummary = false;
  bool _weeklyReport = true;

  // Quiet hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

  // Reminder timing
  int _pillReminderMinutes = 15;

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietStart : _quietEnd,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accentColor,
            surface: AppColors.surfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) { _quietStart = picked; } else { _quietEnd = picked; }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Pill Notifications ──
          const SectionHeader(title: 'Pill Reminders'),
          GlassCard(child: Column(children: [
            _ToggleRow(icon: Icons.medication_rounded, label: 'Pill Reminders', subtitle: 'Get notified when it\'s time to take pills', value: _pillReminders, onChanged: (v) => setState(() => _pillReminders = v)),
            if (_pillReminders) ...[
              const Divider(color: AppColors.divider, height: 24),
              _ToggleRow(icon: Icons.notification_important_outlined, label: 'Missed Pill Alerts', subtitle: 'Alert when you miss a scheduled dose', value: _missedPillAlerts, onChanged: (v) => setState(() => _missedPillAlerts = v)),
              const Divider(color: AppColors.divider, height: 24),
              // Reminder timing
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.timer_outlined, color: AppColors.accentColor, size: 20)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Remind Me Before', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('$_pillReminderMinutes minutes before scheduled time', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ])),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _TimingChip(label: '5 min', selected: _pillReminderMinutes == 5, onTap: () => setState(() => _pillReminderMinutes = 5)),
                const SizedBox(width: 8),
                _TimingChip(label: '10 min', selected: _pillReminderMinutes == 10, onTap: () => setState(() => _pillReminderMinutes = 10)),
                const SizedBox(width: 8),
                _TimingChip(label: '15 min', selected: _pillReminderMinutes == 15, onTap: () => setState(() => _pillReminderMinutes = 15)),
                const SizedBox(width: 8),
                _TimingChip(label: '30 min', selected: _pillReminderMinutes == 30, onTap: () => setState(() => _pillReminderMinutes = 30)),
              ]),
            ],
          ])),
          const SizedBox(height: 24),

          // ── Exercise Notifications ──
          const SectionHeader(title: 'Exercise Reminders'),
          GlassCard(child: _ToggleRow(icon: Icons.fitness_center_rounded, label: 'Exercise Reminders', subtitle: 'Daily exercise session reminders', value: _exerciseReminders, onChanged: (v) => setState(() => _exerciseReminders = v))),
          const SizedBox(height: 24),

          // ── Other Notifications ──
          const SectionHeader(title: 'Other Notifications'),
          GlassCard(child: Column(children: [
            _ToggleRow(icon: Icons.document_scanner_outlined, label: 'Scan Alerts', subtitle: 'Notifications about scan results and updates', value: _scanAlerts, onChanged: (v) => setState(() => _scanAlerts = v)),
            const Divider(color: AppColors.divider, height: 24),
            _ToggleRow(icon: Icons.today_outlined, label: 'Daily Summary', subtitle: 'Receive a daily health summary at 9 PM', value: _dailySummary, onChanged: (v) => setState(() => _dailySummary = v)),
            const Divider(color: AppColors.divider, height: 24),
            _ToggleRow(icon: Icons.date_range_outlined, label: 'Weekly Report', subtitle: 'Get a weekly health progress report', value: _weeklyReport, onChanged: (v) => setState(() => _weeklyReport = v)),
          ])),
          const SizedBox(height: 24),

          // ── Quiet Hours ──
          const SectionHeader(title: 'Quiet Hours'),
          GlassCard(child: Column(children: [
            _ToggleRow(icon: Icons.do_not_disturb_on_outlined, label: 'Quiet Hours', subtitle: 'Silence all notifications during set hours', value: _quietHoursEnabled, onChanged: (v) => setState(() => _quietHoursEnabled = v)),
            if (_quietHoursEnabled) ...[
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _TimePickerTile(label: 'From', time: _formatTime(_quietStart), onTap: () => _pickTime(true))),
                const SizedBox(width: 12),
                Expanded(child: _TimePickerTile(label: 'To', time: _formatTime(_quietEnd), onTap: () => _pickTime(false))),
              ]),
            ],
          ])),
          const SizedBox(height: 28),

          // ── Info ──
          GlassCard(
            borderColor: AppColors.accentColor.withValues(alpha: 0.15),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.info_outline, color: AppColors.accentColor, size: 20)),
              const SizedBox(width: 14),
              const Expanded(child: Text('Notifications use Firebase Cloud Messaging. Make sure notifications are enabled in your device settings.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon; final String label; final String subtitle;
  final bool value; final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.accentColor, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ])),
      Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.accentColor, activeTrackColor: AppColors.accentColor.withValues(alpha: 0.3), inactiveThumbColor: AppColors.textSecondary, inactiveTrackColor: AppColors.cardColor),
    ]);
  }
}

class _TimingChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _TimingChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentColor.withValues(alpha: 0.2) : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accentColor : AppColors.cardColor),
        ),
        child: Text(label, style: TextStyle(color: selected ? AppColors.accentColor : AppColors.textSecondary, fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label; final String time; final VoidCallback onTap;
  const _TimePickerTile({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accentColor.withValues(alpha: 0.2))),
        child: Column(children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: AppColors.accentColor, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
