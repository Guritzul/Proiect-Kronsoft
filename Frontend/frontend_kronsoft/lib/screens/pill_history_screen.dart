import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class PillLogItem {
  final String pillId;
  final String pillName;
  final String dosage;
  final DateTime date;
  final bool isTaken;

  PillLogItem({
    required this.pillId,
    required this.pillName,
    required this.dosage,
    required this.date,
    required this.isTaken,
  });
}

class PillHistoryScreen extends StatefulWidget {
  const PillHistoryScreen({super.key});

  @override
  State<PillHistoryScreen> createState() => _PillHistoryScreenState();
}

class _PillHistoryScreenState extends State<PillHistoryScreen> {
  final _api = ApiService();
  List<PillLogItem> _logs = [];
  bool _loading = true;
  bool _clearing = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _subscription = ApiService.pillHistoryChanged.stream.listen((_) {
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final pills = await _api.getPills();
      final List<PillLogItem> tempLogs = [];
      for (final pill in pills) {
        final id = pill['_id'] ?? pill['id'] ?? '';
        final name = pill['name'] ?? 'Unknown Pill';
        final dosage = pill['dosage'] ?? '';

        final takenDates = pill['takenDates'];
        if (takenDates is List) {
          for (final d in takenDates) {
            try {
              tempLogs.add(
                PillLogItem(
                  pillId: id,
                  pillName: name,
                  dosage: dosage,
                  date: DateTime.parse(d.toString()).toLocal(),
                  isTaken: true,
                ),
              );
            } catch (_) {}
          }
        }

        final missedDates = pill['missedDates'];
        if (missedDates is List) {
          for (final d in missedDates) {
            try {
              tempLogs.add(
                PillLogItem(
                  pillId: id,
                  pillName: name,
                  dosage: dosage,
                  date: DateTime.parse(d.toString()).toLocal(),
                  isTaken: false,
                ),
              );
            } catch (_) {}
          }
        }
      }

      // Sort descending by date
      tempLogs.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _logs = tempLogs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load history: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    setState(() => _clearing = true);
    try {
      await _api.clearPillHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pill history cleared successfully ✓'),
            backgroundColor: context.appColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear history: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
    if (mounted) setState(() => _clearing = false);
  }

  Map<String, List<PillLogItem>> _groupLogsByDay() {
    final Map<String, List<PillLogItem>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final log in _logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      String groupKey;
      if (logDate == today) {
        groupKey = 'Today';
      } else if (logDate == yesterday) {
        groupKey = 'Yesterday';
      } else {
        groupKey = DateFormat('MMMM dd, yyyy').format(log.date);
      }

      if (!groups.containsKey(groupKey)) {
        groups[groupKey] = [];
      }
      groups[groupKey]!.add(log);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(
        title: const Text('Pill History'),
        actions: [
          IconButton(
            icon: _clearing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.appColors.warningColor,
                    ),
                  )
                : Icon(
                    Icons.delete_sweep_rounded,
                    color: context.appColors.warningColor,
                  ),
            tooltip: 'Clear History',
            onPressed: _logs.isEmpty || _clearing
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: context.appColors.surfaceColor,
                        title: const Text('Clear History?'),
                        content: const Text(
                          'This will permanently delete all your pill tracking records.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _clearHistory();
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
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accentColor,
              ),
            )
          : _logs.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
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
              'No pill history yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your taken and missed dose logs will appear here!',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appColors.textHint, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final grouped = _groupLogsByDay();
    return RefreshIndicator(
      color: context.appColors.accentColor,
      backgroundColor: context.appColors.surfaceColor,
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final entry = grouped.entries.elementAt(index);
          final dayTitle = entry.key;
          final dayLogs = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: context.appColors.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dayTitle,
                      style: TextStyle(
                        color: context.appColors.accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ...dayLogs.map((log) => _buildLogCard(log)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogCard(PillLogItem log) {
    final formattedTime = DateFormat('HH:mm').format(log.date);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderColor: log.isTaken
            ? context.appColors.successColor.withValues(alpha: 0.15)
            : context.appColors.dangerColor.withValues(alpha: 0.15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: log.isTaken
                    ? context.appColors.successColor.withValues(alpha: 0.1)
                    : context.appColors.dangerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                log.isTaken ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: log.isTaken
                    ? context.appColors.successColor
                    : context.appColors.dangerColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.pillName,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (log.dosage.isNotEmpty) ...[
                        Text(
                          log.dosage,
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: context.appColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        log.isTaken ? 'Taken at $formattedTime' : 'Missed',
                        style: TextStyle(
                          color: log.isTaken
                              ? context.appColors.successColor
                              : context.appColors.dangerColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
