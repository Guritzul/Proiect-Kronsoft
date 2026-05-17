import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _api = ApiService();
  bool _loading = true;
  SharedPreferences? _prefs;

  // Notification settings
  bool _pillReminders = true;
  bool _missedPillAlerts = true;
  bool _exerciseReminders = true;
  int _pillReminderMinutes = 15;

  // History clearing states
  bool _clearingScan = false;
  bool _clearingPill = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _pillReminders = _prefs?.getBool('notif_pill_reminders') ?? true;
        _missedPillAlerts = _prefs?.getBool('notif_missed_pill_alerts') ?? true;
        _exerciseReminders =
            _prefs?.getBool('notif_exercise_reminders') ?? true;
        _pillReminderMinutes = _prefs?.getInt('notif_pill_reminder_min') ?? 15;
        _loading = false;
      });
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setInt(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(key, value);
  }

  Future<void> _clearScanHistory() async {
    setState(() => _clearingScan = true);
    try {
      await _api.clearScanHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Scan history cleared ✓'),
            backgroundColor: context.appColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
    if (mounted) setState(() => _clearingScan = false);
  }

  Future<void> _clearPillHistory() async {
    setState(() => _clearingPill = true);
    try {
      await _api.clearPillHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pill history cleared ✓'),
            backgroundColor: context.appColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
    if (mounted) setState(() => _clearingPill = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.appColors.bgColor,
        appBar: AppBar(title: const Text('App Settings')),
        body: Center(
          child: CircularProgressIndicator(
            color: context.appColors.accentColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Theme Section
          const SectionHeader(title: 'Appearance'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, ThemeMode currentMode, child) {
                    final isDark = currentMode == ThemeMode.dark;
                    return Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.appColors.accentColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: context.appColors.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isDark ? 'Dark Mode' : 'White Mode',
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: isDark,
                          activeThumbColor: context.appColors.accentColor,
                          activeTrackColor: context.appColors.accentColor
                              .withValues(alpha: 0.3),
                          inactiveThumbColor: context.appColors.textSecondary,
                          inactiveTrackColor: context.appColors.surfaceColor,
                          onChanged: (val) {
                            themeNotifier.value = val
                                ? ThemeMode.dark
                                : ThemeMode.light;
                            _saveBool('app_theme_dark', val);
                          },
                        ),
                      ],
                    );
                  },
                ),
                Divider(color: context.appColors.divider, height: 24),
                Text(
                  'Select Theme Skin',
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<AppSkin>(
                  valueListenable: skinNotifier,
                  builder: (context, AppSkin activeSkin, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSkinOption(
                          context,
                          skin: AppSkin.defaultSkin,
                          activeSkin: activeSkin,
                          name: 'Default',
                          bgColor: const Color(0xFF0F172A),
                          accentColor: const Color(0xFF4DD0E1),
                          isGlass: false,
                        ),
                        _buildSkinOption(
                          context,
                          skin: AppSkin.glassSkin,
                          activeSkin: activeSkin,
                          name: 'Aero Glass',
                          bgColor: const Color(0xFFCBE0FC),
                          accentColor: const Color(0xFF008AD7),
                          isGlass: true,
                        ),
                        _buildSkinOption(
                          context,
                          skin: AppSkin.neonSkin,
                          activeSkin: activeSkin,
                          name: 'Cyber Neon',
                          bgColor: const Color(0xFF020204),
                          accentColor: const Color(0xFF00F3FF),
                          isGlass: false,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          const SectionHeader(title: 'Notifications'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.accentColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        color: context.appColors.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pill Reminders',
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Receive scheduled dose alerts',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _pillReminders,
                      activeThumbColor: context.appColors.accentColor,
                      activeTrackColor: context.appColors.accentColor
                          .withValues(alpha: 0.3),
                      inactiveThumbColor: context.appColors.textSecondary,
                      inactiveTrackColor: context.appColors.surfaceColor,
                      onChanged: (val) {
                        setState(() => _pillReminders = val);
                        _saveBool('notif_pill_reminders', val);
                      },
                    ),
                  ],
                ),
                if (_pillReminders) ...[
                  Divider(color: context.appColors.divider, height: 24),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.appColors.accentColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notification_important_outlined,
                          color: context.appColors.accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missed Dose Alerts',
                              style: TextStyle(
                                color: context.appColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Alerts when a dose is missed',
                              style: TextStyle(
                                color: context.appColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _missedPillAlerts,
                        activeThumbColor: context.appColors.accentColor,
                        activeTrackColor: context.appColors.accentColor
                            .withValues(alpha: 0.3),
                        inactiveThumbColor: context.appColors.textSecondary,
                        inactiveTrackColor: context.appColors.surfaceColor,
                        onChanged: (val) {
                          setState(() => _missedPillAlerts = val);
                          _saveBool('notif_missed_pill_alerts', val);
                        },
                      ),
                    ],
                  ),
                  Divider(color: context.appColors.divider, height: 24),
                  Text(
                    'Remind me before:',
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 30].map((min) {
                      final selected = _pillReminderMinutes == min;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _pillReminderMinutes = min);
                          _saveInt('notif_pill_reminder_min', min);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? context.appColors.accentColor.withValues(
                                    alpha: 0.2,
                                  )
                                : context.appColors.surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? context.appColors.accentColor
                                  : context.appColors.cardColor,
                            ),
                          ),
                          child: Text(
                            '$min min',
                            style: TextStyle(
                              color: selected
                                  ? context.appColors.accentColor
                                  : context.appColors.textSecondary,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                Divider(color: context.appColors.divider, height: 24),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.accentColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: context.appColors.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exercise Reminders',
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Daily exercise reminder alerts',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _exerciseReminders,
                      activeThumbColor: context.appColors.accentColor,
                      activeTrackColor: context.appColors.accentColor
                          .withValues(alpha: 0.3),
                      inactiveThumbColor: context.appColors.textSecondary,
                      inactiveTrackColor: context.appColors.surfaceColor,
                      onChanged: (val) {
                        setState(() => _exerciseReminders = val);
                        _saveBool('notif_exercise_reminders', val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy & Data Section
          const SectionHeader(title: 'Privacy & History'),
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.warningColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_sweep_outlined,
                        color: context.appColors.warningColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clear Scan History',
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Deletes all allergen scan history',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: _clearingScan
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.appColors.warningColor,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: context.appColors.textHint,
                            ),
                      onPressed: _clearingScan
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor:
                                      context.appColors.surfaceColor,
                                  title: const Text('Clear Scan History?'),
                                  content: Text(
                                    'This will permanently delete all your allergen scan records.',
                                    style: TextStyle(
                                      color: context.appColors.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _clearScanHistory();
                                      },
                                      child: Text(
                                        'Clear',
                                        style: TextStyle(
                                          color: context.appColors.dangerColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                    ),
                  ],
                ),
                Divider(color: context.appColors.divider, height: 24),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.warningColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_forever_outlined,
                        color: context.appColors.warningColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clear Pill History',
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Deletes all pill tracking logs',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: _clearingPill
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.appColors.warningColor,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: context.appColors.textHint,
                            ),
                      onPressed: _clearingPill
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor:
                                      context.appColors.surfaceColor,
                                  title: const Text('Clear Pill History?'),
                                  content: Text(
                                    'This will permanently delete all your pill tracking records.',
                                    style: TextStyle(
                                      color: context.appColors.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _clearPillHistory();
                                      },
                                      child: Text(
                                        'Clear',
                                        style: TextStyle(
                                          color: context.appColors.dangerColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinOption(
    BuildContext context, {
    required AppSkin skin,
    required AppSkin activeSkin,
    required String name,
    required Color bgColor,
    required Color accentColor,
    required bool isGlass,
  }) {
    final isSelected = activeSkin == skin;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          skinNotifier.value = skin;
          _saveString('app_skin', skin.toString().split('.').last);
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? context.appColors.accentColor
                      : (isGlass
                            ? Colors.white.withValues(alpha: 0.15)
                            : context.appColors.divider),
                  width: isSelected ? 2 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.appColors.accentColor.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isGlass)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 36,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white30,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      bottom: 4,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: context.appColors.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 9,
                          color: context.appColors.bgColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? context.appColors.accentColor
                    : context.appColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
