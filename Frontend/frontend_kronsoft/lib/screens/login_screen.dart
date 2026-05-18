import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _isForgotPassword = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animCtrl,
            curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animCtrl.forward();
    _loadRememberMe();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', _emailController.text.trim());
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('savedEmail');
    }
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter your email!'),
            ],
          ),
          backgroundColor: context.appColors.dangerColor,
        ),
      );
      return;
    }

    if (!_isForgotPassword && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter your password!'),
            ],
          ),
          backgroundColor: context.appColors.dangerColor,
        ),
      );
      return;
    }

    if (!_isLogin && !_isForgotPassword && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter your name!'),
            ],
          ),
          backgroundColor: context.appColors.dangerColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isForgotPassword) {
        await _authService.sendPasswordResetEmail(email);
        setState(() {
          _isLoading = false;
          _isForgotPassword = false;
          _isLogin = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Password reset email sent! Check your inbox.'),
                ],
              ),
              backgroundColor: context.appColors.successColor,
            ),
          );
        }
      } else if (_isLogin) {
        await _authService.login(email, password);
        await _saveRememberMe();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainShell()),
          );
        }
      } else {
        final credential = await _authService.register(email, password);
        if (name.isNotEmpty) {
          await credential.user?.updateDisplayName(name);
        }
        await _saveRememberMe();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainShell()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.message ?? 'Authentication failed')),
              ],
            ),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('$e')),
              ],
            ),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainShell()),
        );
      }
    } catch (e) {
      debugPrint('Detailed Google Sign-In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Google Sign-In failed: $e')),
              ],
            ),
            backgroundColor: context.appColors.dangerColor,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  String _getSubtext() {
    if (_isForgotPassword) {
      return 'Enter your email to regain access to your account';
    }
    return _isLogin
        ? 'Welcome back! Please enter your credentials'
        : 'Fill in the details below to get started';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AeroBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: context.appColors.cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.appColors.accentColor.withValues(
                            alpha: 0.6,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.accentColor.withValues(
                              alpha: isDark ? 0.35 : 0.20,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        size: 48,
                        color: context.appColors.accentColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'KRONHEALTH',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.textPrimary,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _getSubtext(),
                        key: ValueKey<String>(_getSubtext()),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassCard(
                      padding: const EdgeInsets.all(26),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.06),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: _buildFormContent(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isForgotPassword
                          ? const SizedBox.shrink()
                          : TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _isForgotPassword = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.appColors.textSecondary,
                                    fontFamily: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.fontFamily,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _isLogin
                                          ? "Don't have an account? "
                                          : 'Already have an account? ',
                                    ),
                                    TextSpan(
                                      text: _isLogin ? 'Sign Up' : 'Sign In',
                                      style: TextStyle(
                                        color: context.appColors.accentColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    if (_isForgotPassword) {
      return Column(
        key: const ValueKey<String>('forgot_password_form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: context.appColors.accentColor,
                ),
                onPressed: () {
                  setState(() {
                    _isForgotPassword = false;
                    _isLogin = true;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 10),
              Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'We will send a password reset link to your registered email address. Follow the instructions in the email to regain access.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          AccentButton(
            label: 'Send Password Reset Link',
            isLoading: _isLoading,
            onPressed: _submit,
            icon: Icons.send_rounded,
          ),
        ],
      );
    }

    return Column(
      key: ValueKey<String>(_isLogin ? 'login_form' : 'register_form'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isLogin) ...[
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
        ],
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: context.appColors.accentColor.withValues(alpha: 0.8),
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 10),
        if (_isLogin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value ?? false),
                        activeColor: context.appColors.accentColor,
                        side: BorderSide(
                          color: context.appColors.accentColor.withValues(
                            alpha: 0.6,
                          ),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember Me',
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isForgotPassword = true;
                    _isLogin = false;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: context.appColors.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          )
        else
          const SizedBox(height: 8),
        const SizedBox(height: 20),
        AccentButton(
          label: _isLogin ? 'Sign In' : 'Create Account',
          isLoading: _isLoading,
          onPressed: _submit,
          icon: _isLogin ? Icons.login_rounded : Icons.person_add_alt_1_rounded,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: context.appColors.divider.withValues(alpha: 0.6),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: context.appColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: context.appColors.divider.withValues(alpha: 0.6),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.appColors.textPrimary,
              backgroundColor: context.appColors.surfaceColor.withValues(
                alpha: 0.5,
              ),
              side: BorderSide(
                color: context.appColors.accentColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Image.network(
              'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
              height: 22,
              width: 22,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.g_mobiledata_rounded,
                  size: 28,
                  color: context.appColors.accentColor,
                );
              },
            ),
            label: Text(
              'Google Account',
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: context.appColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.appColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: context.appColors.accentColor.withValues(alpha: 0.8),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.appColors.accentColor.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.appColors.accentColor,
            width: 1.8,
          ),
        ),
        filled: true,
        fillColor: isDark
            ? context.appColors.surfaceColor.withValues(alpha: 0.5)
            : context.appColors.surfaceColor.withValues(alpha: 0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    );
  }
}
