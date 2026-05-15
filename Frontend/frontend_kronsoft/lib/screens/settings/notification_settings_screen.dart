import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

/// Notification settings – pill reminders, exercise reminders, scan alerts, quiet hours.
/// All settings are persisted locally via SharedPreferences.
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

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _pillReminders = prefs.getBool('notif_pill_reminders') ?? true;
        _missedPillAlerts = prefs.getBool('notif_missed_pill_alerts') ?? true;
        _exerciseReminders = prefs.getBool('notif_exercise_reminders') ?? true;
        _scanAlerts = prefs.getBool('notif_scan_alerts') ?? true;
        _dailySummary = prefs.getBool('notif_daily_summary') ?? false;
        _weeklyReport = prefs.getBool('notif_weekly_report') ?? true;
        _quietHoursEnabled = prefs.getBool('notif_quiet_hours') ?? false;
        _quietStart = TimeOfDay(
          hour: prefs.getInt('notif_quiet_start_hour') ?? 22,
          minute: prefs.getInt('notif_quiet_start_min') ?? 0,
        );
        _quietEnd = TimeOfDay(
          hour: prefs.getInt('notif_quiet_end_hour') ?? 7,
          minute: prefs.getInt('notif_quiet_end_min') ?? 0,
        );
        _pillReminderMinutes = prefs.getInt('notif_pill_reminder_min') ?? 15;
        _loaded = true;
      });
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

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
          colorScheme: ColorScheme.dark(
            primary: context.appColors.accentColor,
            surface: context.appColors.surfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietStart = picked;
          _saveInt('notif_quiet_start_hour', picked.hour);
          _saveInt('notif_quiet_start_min', picked.minute);
        } else {
          _quietEnd = picked;
          _saveInt('notif_quiet_end_hour', picked.hour);
          _saveInt('notif_quiet_end_min', picked.minute);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        backgroundColor: context.appColors.bgColor,
        appBar: AppBar(title: Text('Notifications')),
        body: Center(child: CircularProgressIndicator(color: context.appColors.accentColor)),
      );
    }

    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Pill Notifications ──
          const SectionHeader(title: 'Pill Reminders'),
          GlassCard(child: Column(children: [
            _ToggleRow(icon: Icons.medication_rounded, label: 'Pill Reminders', subtitle: 'Get notified when it\'s time to take pills', value: _pillReminders, onChanged: (v) {
              setState(() => _pillReminders = v);
              _saveBool('notif_pill_reminders', v);
            }),
            if (_pillReminders) ...[
              Divider(color: context.appColors.divider, height: 24),
              _ToggleRow(icon: Icons.notification_important_outlined, label: 'Missed Pill Alerts', subtitle: 'Alert when you miss a scheduled dose', value: _missedPillAlerts, onChanged: (v) {
                setState(() => _missedPillAlerts = v);
                _saveBool('notif_missed_pill_alerts', v);
              }),
              Divider(color: context.appColors.divider, height: 24),
              // Reminder timing
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: context.appColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.timer_outlined, color: context.appColors.accentColor, size: 20)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Remind Me Before', style: TextStyle(color: context.appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('$_pillReminderMinutes minutes before scheduled time', style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
                ])),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _TimingChip(label: '5 min', selected: _pillReminderMinutes == 5, onTap: () {
                  setState(() => _pillReminderMinutes = 5);
                  _saveInt('notif_pill_reminder_min', 5);
                }),
                const SizedBox(width: 8),
                _TimingChip(label: '10 min', selected: _pillReminderMinutes == 10, onTap: () {
                  setState(() => _pillReminderMinutes = 10);
                  _saveInt('notif_pill_reminder_min', 10);
                }),
                const SizedBox(width: 8),
                _TimingChip(label: '15 min', selected: _pillReminderMinutes == 15, onTap: () {
                  setState(() => _pillReminderMinutes = 15);
                  _saveInt('notif_pill_reminder_min', 15);
                }),
                const SizedBox(width: 8),
                _TimingChip(label: '30 min', selected: _pillReminderMinutes == 30, onTap: () {
                  setState(() => _pillReminderMinutes = 30);
                  _saveInt('notif_pill_reminder_min', 30);
                }),
              ]),
            ],
          ])),
          const SizedBox(height: 24),

          // ── Exercise Notifications ──
          const SectionHeader(title: 'Exercise Reminders'),
          GlassCard(child: _ToggleRow(icon: Icons.fitness_center_rounded, label: 'Exercise Reminders', subtitle: 'Daily exercise session reminders', value: _exerciseReminders, onChanged: (v) {
            setState(() => _exerciseReminders = v);
            _saveBool('notif_exercise_reminders', v);
          })),
          const SizedBox(height: 24),

          // ── Other Notifications ──
          const SectionHeader(title: 'Other Notifications'),
          GlassCard(child: Column(children: [
            _ToggleRow(icon: Icons.document_scanner_outlined, label: 'Scan Alerts', subtitle: 'Notifications about scan results and updates', value: _scanAlerts, onChanged: (v) {
              setState(() => _scanAlerts = v);
              _saveBool('notif_scan_alerts', v);
            }),
            Divider(color: context.appColors.divider, height: 24),
            _ToggleRow(icon: Icons.today_outlined, label: 'Daily Summary', subtitle: 'Receive a daily health summary at 9 PM', value: _dailySummary, onChanged: (v) {
              setState(() => _dailySummary = v);
              _saveBool('notif_daily_summary', v);
            }),
            Divider(color: context.appColors.divider, height: 24),
            _ToggleRow(icon: Icons.date_range_outlined, label: 'Weekly Report', subtitle: 'Get a weekly health progress report', value: _weeklyReport, onChanged: (v) {
              setState(() => _weeklyReport = v);
              _saveBool('notif_weekly_report', v);
            }),
          ])),
          const SizedBox(height: 24),

          // ── Quiet Hours ──
          const SectionHeader(title: 'Quiet Hours'),
          GlassCard(child: Column(children: [
            _ToggleRow(icon: Icons.do_not_disturb_on_outlined, label: 'Quiet Hours', subtitle: 'Silence all notifications during set hours', value: _quietHoursEnabled, onChanged: (v) {
              setState(() => _quietHoursEnabled = v);
              _saveBool('notif_quiet_hours', v);
            }),
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
            borderColor: context.appColors.accentColor.withValues(alpha: 0.15),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: context.appColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.info_outline, color: context.appColors.accentColor, size: 20)),
              const SizedBox(width: 14),
              Expanded(child: Text('Notifications use Firebase Cloud Messaging. Make sure notifications are enabled in your device settings.', style: TextStyle(color: context.appColors.textSecondary, fontSize: 13, height: 1.4))),
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
      Container(width: 40, height: 40, decoration: BoxDecoration(color: context.appColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: context.appColors.accentColor, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: context.appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
      ])),
      Switch(value: value, onChanged: onChanged, activeThumbColor: context.appColors.accentColor, activeTrackColor: context.appColors.accentColor.withValues(alpha: 0.3), inactiveThumbColor: context.appColors.textSecondary, inactiveTrackColor: context.appColors.cardColor),
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
          color: selected ? context.appColors.accentColor.withValues(alpha: 0.2) : context.appColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? context.appColors.accentColor : context.appColors.cardColor),
        ),
        child: Text(label, style: TextStyle(color: selected ? context.appColors.accentColor : context.appColors.textSecondary, fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
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
        decoration: BoxDecoration(color: context.appColors.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.appColors.accentColor.withValues(alpha: 0.2))),
        child: Column(children: [
          Text(label, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: context.appColors.accentColor, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}