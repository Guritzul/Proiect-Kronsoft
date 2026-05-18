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

  // --- 2. AERO GLASS SKIN PALETTE (Windows 7 Aero Sky Blue / Frosted Ice / Ambient Glow) ---
  static const Color glassAccent = Color(0xFF008AD7); // Classic Aero Blue
  static const Color glassSuccess = Color(
    0xFF2E7D32,
  ); // Deep premium success green
  static const Color glassWarning = Color(0xFFF57C00); // Premium warm amber
  static const Color glassDanger = Color(0xFFD32F2F); // Rich red

  static final glassLight = AppColorsExtension(
    bgColor: Colors
        .transparent, // Fully transparent so the organic AeroBackground shows through
    surfaceColor: const Color(
      0xB3DDEAF0,
    ), // Frosted light ice-blue glass (70% opacity)
    cardColor: const Color(
      0x3DF1F5F9,
    ), // Highly polished crystal card (24% opacity white/slate)
    accentColor: glassAccent,
    accentGlow: glassAccent.withValues(alpha: 0.20),
    accentSubtle: glassAccent.withValues(alpha: 0.08),
    successColor: glassSuccess,
    warningColor: glassWarning,
    dangerColor: glassDanger,
    textPrimary: const Color(0xFF1E293B), // Charcoal slate text
    textSecondary: const Color(0xFF475569),
    textHint: const Color(0xFF94A3B8),
    divider: const Color(0x33008AD7), // Highly translucent blue divider
    shimmer: const Color(0x1A008AD7),
  );

  static final glassDark = AppColorsExtension(
    bgColor: Colors
        .transparent, // Fully transparent so the organic AeroBackground shows through
    surfaceColor: const Color(
      0xCC0F172A,
    ), // Frosted deep slate glass (80% opacity)
    cardColor: const Color(
      0x261E293B,
    ), // Premium dark steel-grey glass card (15% opacity)
    accentColor: const Color(0xFF38BDF8), // Electric Aero cyan
    accentGlow: const Color(0xFF38BDF8).withValues(alpha: 0.25),
    accentSubtle: const Color(0xFF38BDF8).withValues(alpha: 0.12),
    successColor: const Color(0xFF4ADE80),
    warningColor: const Color(0xFFFBBF24),
    dangerColor: const Color(0xFFF87171),
    textPrimary: const Color(0xFFF8FAFC), // Ice-white primary text
    textSecondary: const Color(0xFFCBD5E1),
    textHint: const Color(0xFF64748B),
    divider: const Color(0x3338BDF8),
    shimmer: const Color(0x1A38BDF8),
  );

  // --- 3. NEON CYBERPUNK SKIN PALETTE (Synthwave Pink / Matrix Green / Obsidian Black) ---
  static const Color neonAccentLight = Color(0xFFFF007F); // Hot Neon Pink
  static const Color neonAccentDark = Color(0xFF39FF14); // Electric Neon Green
  static const Color neonSuccess = Color(0xFF00FF66); // Cyber Lime Green
  static const Color neonWarning = Color(0xFFFFEA00); // Electric Neon Yellow
  static const Color neonDanger = Color(0xFFFF0055); // Hot Pink-Red

  static final neonLight = AppColorsExtension(
    bgColor: const Color(0xFFF8FAFC), // ice white-blue
    surfaceColor: const Color(0xFFE2E8F0), // grey-blue
    cardColor: const Color(0xFFFFFFFF),
    accentColor: neonAccentLight,
    accentGlow: neonAccentLight.withValues(alpha: 0.20),
    accentSubtle: neonAccentLight.withValues(alpha: 0.08),
    successColor: neonSuccess,
    warningColor: neonWarning,
    dangerColor: neonDanger,
    textPrimary: const Color(0xFF0F172A), // dark slate
    textSecondary: const Color(0xFF475569),
    textHint: const Color(0xFF94A3B8),
    divider: const Color(0xFFE2E8F0),
    shimmer: const Color(0xFFF1F5F9),
  );

  static final neonDark = AppColorsExtension(
    bgColor: const Color(0xFF000000), // black
    surfaceColor: const Color(0xFF070B07), // green-black
    cardColor: const Color(0xFF0B0E0B), // cyber card
    accentColor: neonAccentDark,
    accentGlow: neonAccentDark.withValues(alpha: 0.30),
    accentSubtle: neonAccentDark.withValues(alpha: 0.12),
    successColor: neonSuccess,
    warningColor: neonWarning,
    dangerColor: neonDanger,
    textPrimary: const Color(0xFFE0FBE0), // white-green glow
    textSecondary: const Color(0xFF88B388), // slate green
    textHint: const Color(0xFF3A593A),
    divider: const Color(0x3339FF14), // green divider
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
    final isNeonSkin = skinNotifier.value == AppSkin.neonSkin;

    if (isGlassSkin) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Stack(
            children: [
              // glass base
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.appColors.cardColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color:
                          borderColor ??
                          context.appColors.accentColor.withValues(alpha: 0.22),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              // glare wave
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: AeroGlassBorderPainter(
                      borderRadius: borderRadius,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      accentColor: context.appColors.accentColor,
                    ),
                  ),
                ),
              ),
              // content
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      );
    }

    if (isNeonSkin) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Stack(
        children: [
          // cyber box
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.cardColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: context.appColors.accentColor.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.accentColor.withValues(
                      alpha: 0.12,
                    ),
                    blurRadius: 16,
                    spreadRadius: -1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // HUD lines
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: CyberCardPainter(
                  borderRadius: borderRadius,
                  isDark: isDark,
                  accentColor: context.appColors.accentColor,
                  dangerColor: context.appColors.dangerColor,
                ),
              ),
            ),
          ),
          // content
          Padding(padding: padding, child: child),
        ],
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              borderColor ??
              context.appColors.accentColor.withValues(alpha: 0.15),
          width: 1.0,
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
    final isGlassSkin = skinNotifier.value == AppSkin.glassSkin;

    Widget buttonContent = DecoratedBox(
      decoration: BoxDecoration(
        gradient: isGlassSkin
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.appColors.accentColor.withValues(alpha: 0.55),
                  context.appColors.accentColor.withValues(alpha: 0.20),
                ],
              )
            : LinearGradient(
                colors: [
                  context.appColors.accentColor,
                  context.appColors.accentColor.withValues(alpha: 0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: isGlassSkin
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: context.appColors.accentColor.withValues(
              alpha: isGlassSkin ? 0.15 : 0.35,
            ),
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
                    Icon(
                      icon,
                      size: 20,
                      color: isGlassSkin
                          ? Colors.white
                          : context.appColors.bgColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isGlassSkin
                          ? Colors.white
                          : context.appColors.bgColor,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isGlassSkin) {
      buttonContent = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: buttonContent,
        ),
      );
    }

    return SizedBox(width: double.infinity, height: 52, child: buttonContent);
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

// Aero Glass Painter
class AeroGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final bool isDark;
  final Color accentColor;

  AeroGlassBorderPainter({
    required this.borderRadius,
    required this.isDark,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // highlight border
    final paintInnerBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.22 : 0.55),
          Colors.white.withValues(alpha: 0.01),
          Colors.white.withValues(alpha: isDark ? 0.05 : 0.15),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paintInnerBorder);

    // curved glare sweep
    final pathGlare = Path();
    pathGlare.moveTo(0, 0);
    pathGlare.lineTo(size.width, 0);
    pathGlare.lineTo(size.width, size.height * 0.38);
    pathGlare.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.18,
      0,
      size.height * 0.32,
    );
    pathGlare.close();

    final paintGlare = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.10 : 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawPath(pathGlare, paintGlare);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AeroGlassBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDark != isDark ||
        oldDelegate.accentColor != accentColor;
  }
}

class AeroBackground extends StatelessWidget {
  final Widget child;
  const AeroBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // wallpaper gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF060914),
                        const Color(0xFF0C101F),
                        const Color(0xFF161C2E),
                      ]
                    : [
                        const Color(0xFFCBE0FC), // light blue
                        const Color(0xFFE9F2FE), // ice white
                        const Color(0xFFBFE3FC), // cyan
                      ],
              ),
            ),
          ),
        ),
        // cyan light
        Positioned(
          top: -120,
          left: -60,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  isDark ? const Color(0x2B00E5FF) : const Color(0x6600E5FF),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // green light
        Positioned(
          bottom: 60,
          right: -120,
          width: 380,
          height: 380,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  isDark ? const Color(0x1B69F0AE) : const Color(0x3F69F0AE),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // amber light
        Positioned(
          top: 180,
          right: -60,
          width: 260,
          height: 260,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  isDark ? const Color(0x14FFD740) : const Color(0x2EFFD740),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // content
        Positioned.fill(child: child),
      ],
    );
  }
}

class CyberCardPainter extends CustomPainter {
  final double borderRadius;
  final bool isDark;
  final Color accentColor;
  final Color dangerColor;

  CyberCardPainter({
    required this.borderRadius,
    required this.isDark,
    required this.accentColor,
    required this.dangerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // crt lines
    final scanlinePaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.03 : 0.05)
      ..strokeWidth = 1.0;

    for (double y = 8; y < size.height; y += 8) {
      canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), scanlinePaint);
    }

    // HUD brackets
    final bracketPaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.85 : 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    const bLen = 14.0;

    // brackets
    canvas.drawPath(
      Path()
        ..moveTo(0, bLen)
        ..lineTo(0, 0)
        ..lineTo(bLen, 0),
      bracketPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - bLen, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, bLen),
      bracketPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - bLen)
        ..lineTo(0, size.height)
        ..lineTo(bLen, size.height),
      bracketPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - bLen, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - bLen),
      bracketPaint,
    );

    // red dots
    final dotPaint = Paint()
      ..color = dangerColor.withValues(alpha: isDark ? 0.8 : 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(bLen + 4, 4), 1.5, dotPaint);
    canvas.drawCircle(
      Offset(size.width - bLen - 4, size.height - 4),
      1.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CyberCardPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDark != isDark ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.dangerColor != dangerColor;
  }
}
