import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'settings/account_settings_screen.dart';
import 'settings/privacy_settings_screen.dart';
import 'settings/notification_settings_screen.dart';

/// Profile screen – user info, allergen settings, and logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _api = ApiService();

  List<String> _allergens = [];
  bool _loadingProfile = true;
  final _allergenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _api.getMyAllergens();
      if (mounted) {
        setState(() {
          _allergens = List<String>.from(data['allergens'] ?? []);
          _loadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _saveAllergens() async {
    try {
      await _api.saveAllergenProfile(_allergens);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Allergens saved ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: context.appColors.dangerColor),
        );
      }
    }
  }

  void _addAllergen() {
    final text = _allergenController.text.trim();
    if (text.isEmpty || _allergens.contains(text)) return;
    setState(() => _allergens.add(text));
    _allergenController.clear();
    _saveAllergens();
  }

  void _removeAllergen(String allergen) {
    setState(() => _allergens.remove(allergen));
    _saveAllergens();
  }

  String get _initials {
    final user = _auth.currentUser;
    final name = user?.displayName ?? user?.email ?? '?';
    final parts = name.split(RegExp(r'[\s@]+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void dispose() {
    _allergenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Avatar & Info ──
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [context.appColors.accentColor, const Color(0xFF26C6DA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.accentColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        color: context.appColors.bgColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: context.appColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Menu Options ──
          _MenuTile(
            icon: Icons.settings_outlined,
            label: 'Account Settings',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
          ),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsScreen())),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          _MenuTile(
            icon: Icons.dark_mode_outlined,
            label: 'Toggle Theme',
            onTap: () {
              // Toggle theme directly
              if (themeNotifier.value == ThemeMode.dark) {
                themeNotifier.value = ThemeMode.light;
              } else {
                themeNotifier.value = ThemeMode.dark;
              }
            },
          ),
          const SizedBox(height: 28),

          // ── Allergens Section ──
          const SectionHeader(title: 'My Allergens'),
          if (_loadingProfile)
            Center(child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(color: context.appColors.accentColor),
            ))
          else ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_allergens.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'No allergens set. Add your allergens so we can protect you.',
                        style: TextStyle(color: context.appColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allergens.map((a) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.appColors.warningColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.appColors.warningColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              a,
                              style: TextStyle(
                                color: context.appColors.warningColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeAllergen(a),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: context.appColors.warningColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _allergenController,
                          style: TextStyle(color: context.appColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add allergen (e.g. Peanuts)',
                            hintStyle: TextStyle(color: context.appColors.textHint, fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            filled: true,
                            fillColor: context.appColors.surfaceColor,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: context.appColors.accentColor.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: context.appColors.accentColor),
                            ),
                          ),
                          onSubmitted: (_) => _addAllergen(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _addAllergen,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: context.appColors.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.add, color: context.appColors.bgColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          // ── Logout ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () async {
                await _auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              },
              icon: Icon(Icons.logout, color: context.appColors.dangerColor),
              label: Text('Logout', style: TextStyle(color: context.appColors.dangerColor, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.appColors.dangerColor.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.appColors.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: context.appColors.accentColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: context.appColors.textHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}