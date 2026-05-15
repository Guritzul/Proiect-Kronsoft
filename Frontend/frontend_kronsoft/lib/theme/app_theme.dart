import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bgColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color accentColor;
  final Color accentGlow;
  final Color accentSubtle;
  final Color successColor;
  final Color warningColor;
  final Color dangerColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color shimmer;

  const AppColorsExtension({
    required this.bgColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.accentColor,
    required this.accentGlow,
    required this.accentSubtle,
    required this.successColor,
    required this.warningColor,
    required this.dangerColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.shimmer,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? bgColor, Color? surfaceColor, Color? cardColor,
    Color? accentColor, Color? accentGlow, Color? accentSubtle,
    Color? successColor, Color? warningColor, Color? dangerColor,
    Color? textPrimary, Color? textSecondary, Color? textHint,
    Color? divider, Color? shimmer,
  }) {
    return AppColorsExtension(
      bgColor: bgColor ?? this.bgColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      cardColor: cardColor ?? this.cardColor,
      accentColor: accentColor ?? this.accentColor,
      accentGlow: accentGlow ?? this.accentGlow,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      dangerColor: dangerColor ?? this.dangerColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      divider: divider ?? this.divider,
      shimmer: shimmer ?? this.shimmer,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmer: Color.lerp(shimmer, other.shimmer, t)!,
    );
  }
}

extension AppColorsGetter on BuildContext {
  AppColorsExtension get appColors => Theme.of(this).extension<AppColorsExtension>()!;
}

class AppTheme {
  // Common Colors
  static const Color accentColor = Color(0xFF4DD0E1);
  static const Color successColor = Color(0xFF66BB6A);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color dangerColor = Color(0xFFEF5350);
  static Color accentGlow = const Color(0xFF4DD0E1).withValues(alpha: 0.20);
  static Color accentSubtle = const Color(0xFF4DD0E1).withValues(alpha: 0.10);

  static final lightColors = AppColorsExtension(
    bgColor: const Color(0xFFF5F5F7),
    surfaceColor: const Color(0xFFFFFFFF),
    cardColor: const Color(0xFFFFFFFF),
    accentColor: accentColor,
    accentGlow: accentGlow,
    accentSubtle: accentSubtle,
    successColor: successColor,
    warningColor: warningColor,
    dangerColor: dangerColor,
    textPrimary: const Color(0xFF1A1A2E),
    textSecondary: const Color(0xFF6E6E8A),
    textHint: const Color(0xFF9E9EB8),
    divider: const Color(0xFFE0E0E0),
    shimmer: const Color(0xFFEEEEEE),
  );

  static final darkColors = AppColorsExtension(
    bgColor: const Color(0xFF0F0F1A),
    surfaceColor: const Color(0xFF1A1A2E),
    cardColor: const Color(0xFF252540),
    accentColor: accentColor,
    accentGlow: accentGlow,
    accentSubtle: accentSubtle,
    successColor: successColor,
    warningColor: warningColor,
    dangerColor: dangerColor,
    textPrimary: const Color(0xFFF0F0F0),
    textSecondary: const Color(0xFF9E9EB8),
    textHint: const Color(0xFF6E6E8A),
    divider: const Color(0xFF2A2A45),
    shimmer: const Color(0xFF3A3A55),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightColors.bgColor,
      extensions: [lightColors],
      colorScheme: ColorScheme.light(
        surface: lightColors.surfaceColor,
        primary: lightColors.accentColor,
        secondary: lightColors.accentColor,
        error: lightColors.dangerColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.bgColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: lightColors.accentColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightColors.surfaceColor,
        selectedItemColor: lightColors.accentColor,
        unselectedItemColor: lightColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: lightColors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColors.surfaceColor,
        labelStyle: TextStyle(color: lightColors.textSecondary),
        hintStyle: TextStyle(color: lightColors.textHint),
        prefixIconColor: lightColors.accentColor,
        suffixIconColor: lightColors.accentColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColors.accentColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColors.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColors.dangerColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColors.dangerColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColors.accentColor,
          foregroundColor: lightColors.bgColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColors.accentColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColors.accentColor,
        foregroundColor: lightColors.bgColor,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightColors.cardColor,
        contentTextStyle: TextStyle(color: lightColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: lightColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: lightColors.divider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightColors.cardColor,
        selectedColor: lightColors.accentColor.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: lightColors.textPrimary, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: lightColors.accentColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: lightColors.accentColor.withValues(alpha: 0.3)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkColors.bgColor,
      extensions: [darkColors],
      colorScheme: ColorScheme.dark(
        surface: darkColors.surfaceColor,
        primary: darkColors.accentColor,
        secondary: darkColors.accentColor,
        error: darkColors.dangerColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.bgColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: darkColors.accentColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkColors.surfaceColor,
        selectedItemColor: darkColors.accentColor,
        unselectedItemColor: darkColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: darkColors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColors.surfaceColor,
        labelStyle: TextStyle(color: darkColors.textSecondary),
        hintStyle: TextStyle(color: darkColors.textHint),
        prefixIconColor: darkColors.accentColor,
        suffixIconColor: darkColors.accentColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.accentColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.dangerColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.dangerColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColors.accentColor,
          foregroundColor: darkColors.bgColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColors.accentColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColors.accentColor,
        foregroundColor: darkColors.bgColor,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkColors.cardColor,
        contentTextStyle: TextStyle(color: darkColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: darkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: darkColors.divider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkColors.cardColor,
        selectedColor: darkColors.accentColor.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: darkColors.textPrimary, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: darkColors.accentColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: darkColors.accentColor.withValues(alpha: 0.3)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGET BUILDERS
// ─────────────────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? context.appColors.accentColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.accentGlow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AccentButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.appColors.accentColor, const Color(0xFF26C6DA)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.appColors.accentColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: context.appColors.bgColor,),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.bgColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const DifficultyBadge({super.key, required this.difficulty});

  Color _getColor(BuildContext context) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return context.appColors.successColor;
      case 'medium':
        return context.appColors.warningColor;
      case 'hard':
        return context.appColors.dangerColor;
      default:
        return context.appColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailing!,
                style: TextStyle(
                  color: context.appColors.accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
