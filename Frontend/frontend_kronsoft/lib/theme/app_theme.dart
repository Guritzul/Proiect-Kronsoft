import 'dart:ui';
import 'package:flutter/material.dart';

enum AppSkin { defaultSkin, glassSkin, neonSkin }

final ValueNotifier<AppSkin> skinNotifier = ValueNotifier(AppSkin.defaultSkin);

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
    Color? bgColor,
    Color? surfaceColor,
    Color? cardColor,
    Color? accentColor,
    Color? accentGlow,
    Color? accentSubtle,
    Color? successColor,
    Color? warningColor,
    Color? dangerColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? shimmer,
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
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
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
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

class AppTheme {
  // --- 1. DEFAULT SKIN PALETTE (Teal / Slate) ---
  static const Color defAccent = Color(0xFF4DD0E1);
  static const Color defSuccess = Color(0xFF66BB6A);
  static const Color defWarning = Color(0xFFFFA726);
  static const Color defDanger = Color(0xFFEF5350);

  static final defaultLight = AppColorsExtension(
    bgColor: const Color(0xFFFFFFFF),
    surfaceColor: const Color(0xFFF8F9FA),
    cardColor: const Color(0xFFFFFFFF),
    accentColor: defAccent,
    accentGlow: defAccent.withValues(alpha: 0.20),
    accentSubtle: defAccent.withValues(alpha: 0.10),
    successColor: defSuccess,
    warningColor: defWarning,
    dangerColor: defDanger,
    textPrimary: const Color(0xFF111827),
    textSecondary: const Color(0xFF6B7280),
    textHint: const Color(0xFF9CA3AF),
    divider: const Color(0xFFE5E7EB),
    shimmer: const Color(0xFFF3F4F6),
  );

  static final defaultDark = AppColorsExtension(
    bgColor: const Color(0xFF05070C),
    surfaceColor: const Color(0xFF0D1017),
    cardColor: const Color(0xFF141824),
    accentColor: defAccent,
    accentGlow: defAccent.withValues(alpha: 0.20),
    accentSubtle: defAccent.withValues(alpha: 0.10),
    successColor: defSuccess,
    warningColor: defWarning,
    dangerColor: defDanger,
    textPrimary: const Color(0xFFF1F5F9),
    textSecondary: const Color(0xFF94A3B8),
    textHint: const Color(0xFF475569),
    divider: const Color(0xFF202638),
    shimmer: const Color(0xFF1E293B),
  );

  // --- 2. GLASSMORPHISM SKIN PALETTE (Orchid / Amethyst / Translucent) ---
  static const Color glassAccent = Color(0xFFBA68C8); // Orchid Purple
  static const Color glassSuccess = Color(0xFF4CAF50);
  static const Color glassWarning = Color(0xFFFFB74D);
  static const Color glassDanger = Color(0xFFE57373);

  static final glassLight = AppColorsExtension(
    bgColor: const Color(0xFFF5F3F9), // Very soft lavender white
    surfaceColor: const Color(0xFFEAE6F3), // Frosted light purple
    cardColor: const Color(
      0xB3FFFFFF,
    ), // Highly translucent glass card (70% opacity)
    accentColor: glassAccent,
    accentGlow: glassAccent.withValues(alpha: 0.25),
    accentSubtle: glassAccent.withValues(alpha: 0.12),
    successColor: glassSuccess,
    warningColor: glassWarning,
    dangerColor: glassDanger,
    textPrimary: const Color(0xFF2E1C4E), // Deep violet text
    textSecondary: const Color(0xFF75629E),
    textHint: const Color(0xFFAB9EC9),
    divider: const Color(0x26BA68C8), // Violet translucent divider
    shimmer: const Color(0x1FBA68C8),
  );

  static final glassDark = AppColorsExtension(
    bgColor: const Color(0xFF0A0714), // Deep outer space violet
    surfaceColor: const Color(0xCC130E26), // Frosted dark purple
    cardColor: const Color(0x801F1836), // Frosted deep card (50% opacity)
    accentColor: const Color(0xFFE040FB), // Neon electric orchid
    accentGlow: const Color(0xFFE040FB).withValues(alpha: 0.30),
    accentSubtle: const Color(0xFFE040FB).withValues(alpha: 0.15),
    successColor: const Color(0xFF69F0AE),
    warningColor: const Color(0xFFFFD740),
    dangerColor: const Color(0xFFFF5252),
    textPrimary: const Color(0xFFF3E8FF), // Lavender white
    textSecondary: const Color(0xFFAC9ECB),
    textHint: const Color(0xFF5D5084),
    divider: const Color(0x33E040FB),
    shimmer: const Color(0x1AE040FB),
  );

  // --- 3. NEON CYBERPUNK SKIN PALETTE (Lime Green / Matrix Black / Cyber Sunset) ---
  static const Color neonAccentLight = Color(0xFFFF6D00); // Solar Orange
  static const Color neonAccentDark = Color(0xFF39FF14); // Electric Neon Green
  static const Color neonSuccess = Color(0xFF00E676);
  static const Color neonWarning = Color(0xFFFFEA00);
  static const Color neonDanger = Color(0xFFFF1744);

  static final neonLight = AppColorsExtension(
    bgColor: const Color(0xFFFFFDE7), // Energetic solar yellow-white
    surfaceColor: const Color(0xFFFFF9C4),
    cardColor: const Color(0xFFFFFFFF),
    accentColor: neonAccentLight,
    accentGlow: neonAccentLight.withValues(alpha: 0.25),
    accentSubtle: neonAccentLight.withValues(alpha: 0.12),
    successColor: neonSuccess,
    warningColor: neonWarning,
    dangerColor: neonDanger,
    textPrimary: const Color(0xFF3E2723), // Dark brown espresso
    textSecondary: const Color(0xFF795548),
    textHint: const Color(0xFFA1887F),
    divider: const Color(0xFFE0F2F1),
    shimmer: const Color(0xFFF5F5F5),
  );

  static final neonDark = AppColorsExtension(
    bgColor: const Color(0xFF000000), // Matrix pitch black
    surfaceColor: const Color(0xFF080D08), // Sleek tactical green-black
    cardColor: const Color(0xFF0F150F), // Deep tech military card
    accentColor: neonAccentDark,
    accentGlow: neonAccentDark.withValues(alpha: 0.35),
    accentSubtle: neonAccentDark.withValues(alpha: 0.18),
    successColor: neonSuccess,
    warningColor: neonWarning,
    dangerColor: neonDanger,
    textPrimary: const Color(0xFFE0FBE0), // Electric white-green
    textSecondary: const Color(0xFF7CA87C),
    textHint: const Color(0xFF3B563B),
    divider: const Color(0x3339FF14),
    shimmer: const Color(0x1F39FF14),
  );

  static AppColorsExtension getColorsFor(AppSkin skin, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (skin) {
      case AppSkin.defaultSkin:
        return isDark ? defaultDark : defaultLight;
      case AppSkin.glassSkin:
        return isDark ? glassDark : glassLight;
      case AppSkin.neonSkin:
        return isDark ? neonDark : neonLight;
    }
  }

  static ThemeData getThemeFor(AppSkin skin, Brightness brightness) {
    final colors = getColorsFor(skin, brightness);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bgColor,
      extensions: [colors],
      colorScheme: isDark
          ? ColorScheme.dark(
              surface: colors.surfaceColor,
              primary: colors.accentColor,
              secondary: colors.accentColor,
              error: colors.dangerColor,
            )
          : ColorScheme.light(
              surface: colors.surfaceColor,
              primary: colors.accentColor,
              secondary: colors.accentColor,
              error: colors.dangerColor,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: colors.accentColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surfaceColor,
        selectedItemColor: colors.accentColor,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: colors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceColor,
        labelStyle: TextStyle(color: colors.textSecondary),
        hintStyle: TextStyle(color: colors.textHint),
        prefixIconColor: colors.accentColor,
        suffixIconColor: colors.accentColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.accentColor.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.dangerColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.dangerColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentColor,
          foregroundColor: colors.bgColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accentColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accentColor,
        foregroundColor: colors.bgColor,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.cardColor,
        contentTextStyle: TextStyle(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: colors.cardColor,
        selectedColor: colors.accentColor.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: colors.textPrimary, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: colors.accentColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: colors.accentColor.withValues(alpha: 0.3)),
      ),
    );
  }

  // Backwards compatibility wrappers
  static ThemeData get lightTheme =>
      getThemeFor(AppSkin.defaultSkin, Brightness.light);
  static ThemeData get darkTheme =>
      getThemeFor(AppSkin.defaultSkin, Brightness.dark);
}

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
    final isGlassSkin = skinNotifier.value == AppSkin.glassSkin;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              borderColor ??
              context.appColors.accentColor.withValues(alpha: 0.15),
          width: isGlassSkin ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.accentGlow.withValues(
              alpha: isGlassSkin ? 0.08 : 0.06,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (isGlassSkin) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: cardContent,
        ),
      );
    }

    return cardContent;
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
            colors: [
              context.appColors.accentColor,
              context.appColors.accentColor.withValues(alpha: 0.8),
            ],
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                      Icon(icon, size: 20, color: context.appColors.bgColor),
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
