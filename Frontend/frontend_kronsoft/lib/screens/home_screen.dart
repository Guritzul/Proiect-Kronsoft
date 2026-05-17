import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  Map<String, dynamic>? _dashboard;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await _api.getDashboard();
      if (mounted) setState(() => _dashboard = data);
    } catch (_) {}
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  String get _userName {
    final user = AuthService().currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return user?.email?.split('@').first ?? 'User';
  }

  Widget _buildHeader() {
    final initials = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting.toUpperCase(),
                style: TextStyle(
                  color: context.appColors.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userName,
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Stay healthy, stay strong 💪',
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.appColors.accentColor.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: context.appColors.accentColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: context.appColors.cardColor,
            child: Text(
              initials,
              style: TextStyle(
                color: context.appColors.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
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
                _buildHeader(),
                const SizedBox(height: 28),

                if (_dashboard != null) ...[
                  Row(
                    children: [
                      _SummaryTile(
                        icon: Icons.medication_rounded,
                        label: 'Active Pills',
                        value:
                            '${(_dashboard!['pills'] as List?)?.length ?? 0}',
                        color: context.appColors.accentColor,
                      ),
                      const SizedBox(width: 12),
                      _SummaryTile(
                        icon: Icons.warning_amber_rounded,
                        label: 'Allergens',
                        value:
                            '${(_dashboard!['allergens'] as List?)?.length ?? 0}',
                        color: context.appColors.warningColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_dashboard!['lastScan'] != null)
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: context.appColors.successColor.withValues(alpha: 0.15),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: context.appColors.successColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.appColors.successColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              color: context.appColors.successColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Scan Status',
                                  style: TextStyle(
                                    color: context.appColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _dashboard!['lastScan']['status'] ?? 'SAFE',
                                  style: TextStyle(
                                    color: context.appColors.successColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
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

                const SectionHeader(title: 'Quick Access'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.05,
                  children: [
                    _QuickNavCard(
                      icon: Icons.document_scanner_rounded,
                      title: 'Allergen\nDetection',
                      gradient: [
                        const Color(0xFF4DD0E1),
                        const Color(0xFF26C6DA),
                      ],
                      onTap: () => _jumpToTab(1),
                    ),
                    _QuickNavCard(
                      icon: Icons.medication_rounded,
                      title: 'Pill\nTracking',
                      gradient: [
                        const Color(0xFF7C4DFF),
                        const Color(0xFF651FFF),
                      ],
                      onTap: () => _jumpToTab(2),
                    ),
                    _QuickNavCard(
                      icon: Icons.fitness_center_rounded,
                      title: 'Recovery\nExercises',
                      gradient: [
                        const Color(0xFFFF6E40),
                        const Color(0xFFFF3D00),
                      ],
                      onTap: () => _jumpToTab(3),
                    ),
                    _QuickNavCard(
                      icon: Icons.person_rounded,
                      title: 'My\nProfile',
                      gradient: [
                        const Color(0xFF66BB6A),
                        const Color(0xFF43A047),
                      ],
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
    final shellState = context.findAncestorStateOfType<MainShellState>();
    if (shellState != null) {
      shellState.switchTab(index);
    }
  }
}

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
        borderColor: color.withValues(alpha: 0.15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.appColors.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gradient[0].withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -15,
              right: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: gradient[0].withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: gradient[0].withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: gradient[0], size: 20),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TAP TO OPEN',
                        style: TextStyle(
                          color: gradient[0],
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: gradient[0],
                        size: 14,
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
