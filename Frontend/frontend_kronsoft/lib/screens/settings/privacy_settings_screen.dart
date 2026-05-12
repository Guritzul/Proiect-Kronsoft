import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

/// Privacy settings – data sharing, visibility, and data management options.
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});
  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _api = ApiService();

  // Local toggle state (in a real app these would persist to backend/shared_preferences)
  bool _shareHealthData = false;
  bool _shareActivityStats = true;
  bool _profileVisible = false;
  bool _analyticsEnabled = true;
  bool _crashReporting = true;

  bool _clearingScanHistory = false;
  bool _clearingPillHistory = false;

  Future<void> _clearScanHistory() async {
    setState(() => _clearingScanHistory = true);
    try {
      await _api.clearScanHistory();
      if (mounted) {
        setState(() => _clearingScanHistory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan history cleared ✓'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _clearingScanHistory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear scan history: $e'),
            backgroundColor: AppColors.dangerColor,
          ),
        );
      }
    }
  }

  Future<void> _clearPillHistory() async {
    setState(() => _clearingPillHistory = true);
    try {
      await _api.clearPillHistory();
      if (mounted) {
        setState(() => _clearingPillHistory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pill history cleared ✓'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _clearingPillHistory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear pill history: $e'),
            backgroundColor: AppColors.dangerColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Data Sharing ──
          const SectionHeader(title: 'Data Sharing'),
          GlassCard(child: Column(children: [
            _ToggleRow(
              icon: Icons.favorite_outline,
              label: 'Share Health Data',
              subtitle: 'Allow sharing pill and allergen data with your doctor',
              value: _shareHealthData,
              onChanged: (v) => setState(() => _shareHealthData = v),
            ),
            const Divider(color: AppColors.divider, height: 24),
            _ToggleRow(
              icon: Icons.bar_chart_rounded,
              label: 'Share Activity Stats',
              subtitle: 'Include exercise stats in shared reports',
              value: _shareActivityStats,
              onChanged: (v) => setState(() => _shareActivityStats = v),
            ),
          ])),
          const SizedBox(height: 24),

          // ── Visibility ──
          const SectionHeader(title: 'Visibility'),
          GlassCard(child: Column(children: [
            _ToggleRow(
              icon: Icons.visibility_outlined,
              label: 'Profile Visible',
              subtitle: 'Let other users see your profile info',
              value: _profileVisible,
              onChanged: (v) => setState(() => _profileVisible = v),
            ),
          ])),
          const SizedBox(height: 24),

          // ── Analytics ──
          const SectionHeader(title: 'Analytics & Diagnostics'),
          GlassCard(child: Column(children: [
            _ToggleRow(
              icon: Icons.analytics_outlined,
              label: 'Usage Analytics',
              subtitle: 'Help us improve by sharing anonymous usage data',
              value: _analyticsEnabled,
              onChanged: (v) => setState(() => _analyticsEnabled = v),
            ),
            const Divider(color: AppColors.divider, height: 24),
            _ToggleRow(
              icon: Icons.bug_report_outlined,
              label: 'Crash Reporting',
              subtitle: 'Automatically send crash reports',
              value: _crashReporting,
              onChanged: (v) => setState(() => _crashReporting = v),
            ),
          ])),
          const SizedBox(height: 24),

          // ── Data Management ──
          const SectionHeader(title: 'Your Data'),
          _ActionTile(
            icon: Icons.download_rounded,
            label: 'Export My Data',
            subtitle: 'Download all your health data as JSON',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export will be available soon')),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.delete_sweep_outlined,
            label: 'Clear Scan History',
            subtitle: 'Remove all allergen scan records',
            color: AppColors.warningColor,
            isLoading: _clearingScanHistory,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceColor,
                  title: const Text('Clear Scan History?'),
                  content: const Text('This will permanently delete all your allergen scan history.', style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearScanHistory();
                      },
                      child: const Text('Clear', style: TextStyle(color: AppColors.dangerColor)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.delete_forever_outlined,
            label: 'Clear Pill History',
            subtitle: 'Remove all pill tracking records',
            color: AppColors.warningColor,
            isLoading: _clearingPillHistory,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceColor,
                  title: const Text('Clear Pill History?'),
                  content: const Text('This will permanently delete all your pill tracking history.', style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearPillHistory();
                      },
                      child: const Text('Clear', style: TextStyle(color: AppColors.dangerColor)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Info card ──
          GlassCard(
            borderColor: AppColors.accentColor.withValues(alpha: 0.15),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.shield_outlined, color: AppColors.accentColor, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text(
                'Your data is encrypted and stored securely. We never sell your personal information.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              )),
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
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.accentColor, size: 20),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ])),
      Switch(
        value: value, onChanged: onChanged,
        activeThumbColor: AppColors.accentColor,
        activeTrackColor: AppColors.accentColor.withValues(alpha: 0.3),
        inactiveThumbColor: AppColors.textSecondary,
        inactiveTrackColor: AppColors.cardColor,
      ),
    ]);
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final String subtitle;
  final VoidCallback onTap; final Color? color; final bool isLoading;

  const _ActionTile({required this.icon, required this.label, required this.subtitle, required this.onTap, this.color, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accentColor;
    return Material(color: AppColors.cardColor, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: isLoading ? null : onTap, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: isLoading
          ? Padding(padding: const EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: c))
          : Icon(icon, color: c, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ])),
      Icon(Icons.chevron_right, color: c.withValues(alpha: 0.5), size: 20),
    ]))));
  }
}
