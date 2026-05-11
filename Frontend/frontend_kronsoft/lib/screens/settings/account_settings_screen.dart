import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});
  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _auth = AuthService();
  final _nameController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = _auth.currentUser?.displayName ?? '';
  }

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  Future<void> _updateDisplayName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await _auth.currentUser?.updateDisplayName(name);
      await _auth.currentUser?.reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name updated ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.dangerColor),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _showChangePasswordDialog() {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPwCtrl, obscureText: obscureCurrent,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Current Password', prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: newPwCtrl, obscureText: obscureNew,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'New Password', prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: confirmPwCtrl, obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Confirm New Password', prefixIcon: Icon(Icons.lock)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: loading ? null : () async {
                if (newPwCtrl.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: AppColors.warningColor),
                  );
                  return;
                }
                if (newPwCtrl.text != confirmPwCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.warningColor),
                  );
                  return;
                }
                setDialogState(() => loading = true);
                try {
                  final cred = EmailAuthProvider.credential(email: _auth.currentUser!.email!, password: currentPwCtrl.text);
                  await _auth.currentUser!.reauthenticateWithCredential(cred);
                  await _auth.currentUser!.updatePassword(newPwCtrl.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed ✓')));
                } catch (e) {
                  setDialogState(() => loading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: ${e.toString().contains('wrong-password') ? 'Wrong current password' : e}'), backgroundColor: AppColors.dangerColor),
                    );
                  }
                }
              },
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Change', style: TextStyle(color: AppColors.accentColor)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final pwCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: const Row(children: [
          Icon(Icons.warning_rounded, color: AppColors.dangerColor, size: 24),
          SizedBox(width: 10),
          Text('Delete Account'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action is permanent. All data will be lost.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
            const SizedBox(height: 16),
            TextField(
              controller: pwCtrl, obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Enter password to confirm', prefixIcon: Icon(Icons.lock_outline)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (pwCtrl.text.isEmpty) return;
              try {
                final cred = EmailAuthProvider.credential(email: _auth.currentUser!.email!, password: pwCtrl.text);
                await _auth.currentUser!.reauthenticateWithCredential(cred);
                await _auth.currentUser!.delete();
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: ${e.toString().contains('wrong-password') ? 'Wrong password' : e}'), backgroundColor: AppColors.dangerColor),
                  );
                }
              }
            },
            child: const Text('Delete Forever', style: TextStyle(color: AppColors.dangerColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final email = user?.email ?? '';
    final createdAt = user?.metadata.creationTime;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Display Name
          const SectionHeader(title: 'Display Name'),
          GlassCard(child: Column(children: [
            TextField(controller: _nameController, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 14),
            AccentButton(label: 'Save Name', icon: Icons.save_rounded, isLoading: _saving, onPressed: _updateDisplayName),
          ])),
          const SizedBox(height: 24),

          // Email
          const SectionHeader(title: 'Email Address'),
          GlassCard(child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.accentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.email_outlined, color: AppColors.accentColor, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(email, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(user?.emailVerified == true ? 'Verified ✓' : 'Not verified', style: TextStyle(color: user?.emailVerified == true ? AppColors.successColor : AppColors.warningColor, fontSize: 12)),
            ])),
            if (user?.emailVerified != true)
              TextButton(onPressed: () async { final messenger = ScaffoldMessenger.of(context); try { await user?.sendEmailVerification(); messenger.showSnackBar(const SnackBar(content: Text('Verification email sent ✓'))); } catch (_) {} }, child: const Text('Verify', style: TextStyle(fontSize: 12))),
          ])),
          const SizedBox(height: 24),

          // Security
          const SectionHeader(title: 'Security'),
          _ActionTile(icon: Icons.lock_outline, label: 'Change Password', subtitle: 'Update your login password', onTap: _showChangePasswordDialog),
          const SizedBox(height: 24),

          // Account Info
          const SectionHeader(title: 'Account Info'),
          GlassCard(child: Column(children: [
            _InfoRow(label: 'User ID', value: user?.uid ?? '—'),
            const Divider(color: AppColors.divider, height: 20),
            _InfoRow(label: 'Member Since', value: createdAt != null ? '${createdAt.day}/${createdAt.month}/${createdAt.year}' : '—'),
            const Divider(color: AppColors.divider, height: 20),
            _InfoRow(label: 'Auth Provider', value: user?.providerData.isNotEmpty == true ? user!.providerData.first.providerId : 'email'),
          ])),
          const SizedBox(height: 32),

          // Danger Zone
          const SectionHeader(title: 'Danger Zone'),
          Container(
            decoration: BoxDecoration(color: AppColors.dangerColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.dangerColor.withValues(alpha: 0.2))),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.warning_amber_rounded, color: AppColors.dangerColor, size: 20), SizedBox(width: 8), Text('Delete Account', style: TextStyle(color: AppColors.dangerColor, fontSize: 16, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 8),
              const Text('Permanently delete your account and all data. This cannot be undone.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 44, child: OutlinedButton(onPressed: _showDeleteAccountDialog, style: OutlinedButton.styleFrom(foregroundColor: AppColors.dangerColor, side: const BorderSide(color: AppColors.dangerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Delete My Account', style: TextStyle(fontWeight: FontWeight.w700)))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final String subtitle; final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(color: AppColors.cardColor, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.accentColor, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ])),
      const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
    ]))));
  }
}

class _InfoRow extends StatelessWidget {
  final String label; final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Flexible(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
    ]);
  }
}
