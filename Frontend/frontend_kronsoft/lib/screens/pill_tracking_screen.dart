import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/local_notification_service.dart';

class PillTrackingScreen extends StatefulWidget {
  const PillTrackingScreen({super.key});

  @override
  State<PillTrackingScreen> createState() => _PillTrackingScreenState();
}

class _PillTrackingScreenState extends State<PillTrackingScreen> {
  final _api = ApiService();
  List<dynamic> _pills = [];
  bool _loading = true;
  final Set<String> _takenIds = {};

  @override
  void initState() {
    super.initState();
    _loadPills();
  }

  Future<void> _loadPills() async {
    try {
      final data = await _api.getPills();
      if (mounted) {
        setState(() {
          _pills = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markTaken(Map<String, dynamic> pill) async {
    final id = pill['_id'] ?? pill['id'] ?? '';
    setState(() => _takenIds.add(id));
    try {
      await _api.markPillTaken(id);

      // Reschedule to skip today's missed pill alert
      final prefs = await SharedPreferences.getInstance();
      final missedAlerts = prefs.getBool('notif_missed_pill_alerts') ?? true;
      final reminderMin = prefs.getInt('notif_pill_reminder_min') ?? 15;

      await LocalNotificationService.schedulePillNotifications(
        pillId: id.hashCode.abs() % 100000,
        pillMongoId: id,
        pillName: pill['name'] ?? '',
        dosage: pill['dosage'] ?? '',
        schedule: List<String>.from(pill['schedule'] ?? []),
        reminderMinutes: reminderMin,
        missedPillAlerts: missedAlerts,
      );
    } catch (_) {
      if (mounted) setState(() => _takenIds.remove(id));
    }
  }

  Future<void> _markMissed(String id) async {
    try {
      await _api.markPillMissed(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Marked as missed')));
      }
    } catch (_) {}
  }

  Future<void> _deletePill(String id, int pillId) async {
    try {
      await _api.deletePill(id);
      await LocalNotificationService.cancelPillNotifications(pillId);
      _loadPills();
    } catch (_) {}
  }

  void _showAddPillSheet() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textSecondary.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add New Pill',
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: context.appColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Pill Name',
                prefixIcon: Icon(Icons.medication),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: dosageCtrl,
              style: TextStyle(color: context.appColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g. 500mg)',
                prefixIcon: Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: timeCtrl,
              style: TextStyle(color: context.appColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Schedule (e.g. 08:00, 20:00)',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 24),
            AccentButton(
              label: 'Save Pill',
              icon: Icons.save_rounded,
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  final pill = await _api.createPill({
                    'name': nameCtrl.text.trim(),
                    'dosage': dosageCtrl.text.trim(),
                    'schedule': timeCtrl.text
                        .trim()
                        .split(',')
                        .map((s) => s.trim())
                        .toList(),
                  });

                  final prefs = await SharedPreferences.getInstance();
                  final pillRemindersEnabled = prefs.getBool('notif_pill_reminders') ?? true;
                  final reminderMin = pillRemindersEnabled
                      ? (prefs.getInt('notif_pill_reminder_min') ?? 15)
                      : 0;
                  final missedAlerts = prefs.getBool('notif_missed_pill_alerts') ?? true;

                  await LocalNotificationService.schedulePillNotifications(
                    pillId: pill['_id'].toString().hashCode.abs() % 100000,
                    pillMongoId: pill['_id'].toString(),
                    pillName: nameCtrl.text.trim(),
                    dosage: dosageCtrl.text.trim(),
                    schedule: timeCtrl.text
                        .trim()
                        .split(',')
                        .map((s) => s.trim())
                        .toList(),
                    reminderMinutes: reminderMin,
                    missedPillAlerts: missedAlerts,
                  );

                  _loadPills();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          reminderMin > 0
                              ? '✅ Pill saved! Reminder set $reminderMin min before.'
                              : '✅ Pill saved!',
                        ),
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
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(title: const Text('Pill Tracking')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPillSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Pill'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accentColor,
              ),
            )
          : RefreshIndicator(
              color: context.appColors.accentColor,
              backgroundColor: context.appColors.surfaceColor,
              onRefresh: _loadPills,
              child: _pills.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 64,
                                color: context.appColors.textSecondary
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No pills added yet',
                                style: TextStyle(
                                  color: context.appColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap + to add your first pill',
                                style: TextStyle(
                                  color: context.appColors.textHint,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      itemCount: _pills.length + 1,
                      itemBuilder: (context, i) {
                        if (i == _pills.length) return _buildTipCard();
                        return _buildPillCard(_pills[i]);
                      },
                    ),
            ),
    );
  }

  Widget _buildPillCard(Map<String, dynamic> pill) {
    final id = pill['_id'] ?? pill['id'] ?? '';
    final pillId = id.hashCode;
    final name = pill['name'] ?? 'Unknown';
    final dosage = pill['dosage'] ?? '';
    final schedule = pill['schedule'];
    final taken = _takenIds.contains(id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: context.appColors.dangerColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.delete_outline,
            color: context.appColors.dangerColor,
            size: 28,
          ),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Pill'),
              content: Text('Remove "$name" from your list?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: context.appColors.dangerColor),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => _deletePill(id, pillId),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: taken
              ? context.appColors.successColor.withValues(alpha: 0.3)
              : context.appColors.accentColor.withValues(alpha: 0.12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: taken
                      ? context.appColors.successColor.withValues(alpha: 0.15)
                      : context.appColors.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  taken ? Icons.check_circle : Icons.medication_rounded,
                  color: taken
                      ? context.appColors.successColor
                      : context.appColors.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: taken ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (dosage.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        dosage,
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (schedule != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: context.appColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule is List
                                ? schedule.join(', ')
                                : schedule.toString(),
                            style: TextStyle(
                              color: context.appColors.textHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!taken) ...[
                IconButton(
                  onPressed: () => _markTaken(pill),
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: context.appColors.successColor,
                  ),
                  tooltip: 'Mark as taken',
                ),
                IconButton(
                  onPressed: () => _markMissed(id),
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: context.appColors.warningColor,
                    size: 22,
                  ),
                  tooltip: 'Mark as missed',
                ),
              ] else
                Icon(Icons.done_all, color: context.appColors.successColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GlassCard(
        borderColor: context.appColors.warningColor.withValues(alpha: 0.2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.appColors.warningColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tips_and_updates,
                color: context.appColors.warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Forgot a pill? Don\'t worry, just ask your doctor for advice.',
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
