import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

/// Dashboard home screen – shows greeting, quick-nav cards, and summary data.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _api = ApiService();
  Map<String, dynamic>? _dashboard;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await _api.getDashboard();
      if (mounted) setState(() => _dashboard = data);
    } catch (_) {
      // Dashboard load failed silently
    }
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _userName {
    final user = AuthService().currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return user?.email?.split('@').first ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: RefreshIndicator(
            color: context.appColors.accentColor,
            backgroundColor: context.appColors.surfaceColor,
            onRefresh: _loadDashboard,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                // ── Greeting ──
                Text(
                  _greeting,
                  style: TextStyle(color: context.appColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay healthy, stay strong 💪',
                  style: TextStyle(
                    color: context.appColors.accentColor.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Summary Cards Row ──
                if (_dashboard != null) ...[
                  Row(
                    children: [
                      _SummaryTile(
                        icon: Icons.medication,
                        label: 'Active Pills',
                        value: '${(_dashboard!['pills'] as List?)?.length ?? 0}',
                        color: context.appColors.accentColor,
                      ),
                      const SizedBox(width: 12),
                      _SummaryTile(
                        icon: Icons.warning_amber_rounded,
                        label: 'Allergens',
                        value: '${(_dashboard!['allergens'] as List?)?.length ?? 0}',
                        color: context.appColors.warningColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_dashboard!['lastScan'] != null)
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: context.appColors.successColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.qr_code_scanner, color: context.appColors.successColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Last Scan', style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  _dashboard!['lastScan']['status'] ?? 'SAFE',
                                  style: TextStyle(
                                    color: context.appColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 28),
                ],

                // ── Quick Navigation ──
                const SectionHeader(title: 'Quick Access'),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    _QuickNavCard(
                      icon: Icons.document_scanner,
                      title: 'Allergen\nDetection',
                      gradient: [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)],
                      onTap: () => _jumpToTab(1),
                    ),
                    _QuickNavCard(
                      icon: Icons.medication_rounded,
                      title: 'Pill\nTracking',
                      gradient: [const Color(0xFF7C4DFF), const Color(0xFF651FFF)],
                      onTap: () => _jumpToTab(2),
                    ),
                    _QuickNavCard(
                      icon: Icons.fitness_center_rounded,
                      title: 'Recovery\nExercises',
                      gradient: [const Color(0xFFFF6E40), const Color(0xFFFF3D00)],
                      onTap: () => _jumpToTab(3),
                    ),
                    _QuickNavCard(
                      icon: Icons.person_rounded,
                      title: 'My\nProfile',
                      gradient: [const Color(0xFF66BB6A), const Color(0xFF43A047)],
                      onTap: () => _jumpToTab(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _jumpToTab(int index) {
    // Walk up to MainShell and change tab
    final shellState = context.findAncestorStateOfType<MainShellState>();
    if (shellState != null) {
      shellState.switchTab(index);
    }
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
                Text(label, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickNavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickNavCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradient[0].withValues(alpha: 0.18), gradient[1].withValues(alpha: 0.06)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gradient[0].withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: gradient[0].withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: gradient[0], size: 24),
            ),
            Text(
              title,
              style: TextStyle(
                color: gradient[0],
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}