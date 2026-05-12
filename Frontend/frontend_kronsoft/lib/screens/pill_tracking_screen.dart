import 'package:flutter/material.dart';
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
  final int _reminderMinutes = 15;

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

  Future<void> _markTaken(String id) async {
    setState(() => _takenIds.add(id));
    try {
      await _api.markPillTaken(id);
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
    int selectedReminder = _reminderMinutes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add New Pill',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Pill Name',
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: dosageCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g. 500mg)',
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: timeCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Schedule (e.g. 08:00, 20:00)',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remind me before:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [5, 10, 15, 30].map((min) {
                  final selected = selectedReminder == min;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setSheetState(() => selectedReminder = min),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accentColor.withValues(alpha: 0.2)
                              : AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.accentColor
                                : AppColors.cardColor,
                          ),
                        ),
                        child: Text(
                          '$min min',
                          style: TextStyle(
                            color: selected
                                ? AppColors.accentColor
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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

                    await LocalNotificationService.schedulePillNotifications(
                      pillId: pill['_id'].toString().hashCode.abs() % 100000,
                      pillName: nameCtrl.text.trim(),
                      dosage: dosageCtrl.text.trim(),
                      schedule: timeCtrl.text
                          .trim()
                          .split(',')
                          .map((s) => s.trim())
                          .toList(),
                      reminderMinutes: selectedReminder,
                    );

                    _loadPills();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ Pill saved! Reminder set $selectedReminder min before.',
                          ),
                          backgroundColor: AppColors.successColor,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed: $e'),
                          backgroundColor: AppColors.dangerColor,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text('Pill Tracking')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPillSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Pill'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentColor),
            )
          : RefreshIndicator(
              color: AppColors.accentColor,
              backgroundColor: AppColors.surfaceColor,
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
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No pills added yet',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tap + to add your first pill',
                                style: TextStyle(
                                  color: AppColors.textHint,
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
            color: AppColors.dangerColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: AppColors.dangerColor,
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
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.dangerColor),
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
              ? AppColors.successColor.withValues(alpha: 0.3)
              : AppColors.accentColor.withValues(alpha: 0.12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: taken
                      ? AppColors.successColor.withValues(alpha: 0.15)
                      : AppColors.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  taken ? Icons.check_circle : Icons.medication_rounded,
                  color: taken ? AppColors.successColor : AppColors.accentColor,
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
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: taken ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (dosage.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        dosage,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (schedule != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule is List
                                ? schedule.join(', ')
                                : schedule.toString(),
                            style: const TextStyle(
                              color: AppColors.textHint,
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
                  onPressed: () => _markTaken(id),
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successColor,
                  ),
                  tooltip: 'Mark as taken',
                ),
                IconButton(
                  onPressed: () => _markMissed(id),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: AppColors.warningColor,
                    size: 22,
                  ),
                  tooltip: 'Mark as missed',
                ),
              ] else
                const Icon(Icons.done_all, color: AppColors.successColor),
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
        borderColor: AppColors.warningColor.withValues(alpha: 0.2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warningColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tips_and_updates,
                color: AppColors.warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Forgot a pill? Don\'t worry, just ask your doctor for advice.',
                style: TextStyle(
                  color: AppColors.textSecondary,
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
