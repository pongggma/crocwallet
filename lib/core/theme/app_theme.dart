import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';
import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final palette = isDark ? AppPalette.dark : AppPalette.light;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final outline = isDark ? AppColors.outlineDark : AppColors.outlineLight;
    final primary = isDark ? AppColors.primaryBright : AppColors.primary;

    final scheme = ColorScheme(
      brightness: b,
      primary: primary,
      onPrimary: const Color(0xFF182013),
      primaryContainer: isDark ? const Color(0xFF34452C) : AppColors.primarySoft,
      onPrimaryContainer: isDark ? const Color(0xFFE2EED5) : AppColors.primaryDark,
      secondary: palette.water,
      onSecondary: const Color(0xFF3C2414),
      secondaryContainer: isDark ? const Color(0xFF4C3325) : const Color(0xFFFFE7D3),
      onSecondaryContainer: isDark ? const Color(0xFFFFE1C7) : const Color(0xFF6D3915),
      tertiary: palette.gold,
      onTertiary: const Color(0xFF2B1F00),
      tertiaryContainer: palette.goldSoft,
      onTertiaryContainer: isDark ? const Color(0xFFFFE9A8) : AppColors.goldDeep,
      error: palette.expense,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF4A1D20) : const Color(0xFFFADADB),
      onErrorContainer: isDark ? const Color(0xFFFFD6D8) : const Color(0xFF6B1418),
      surface: surface,
      onSurface: palette.ink,
      onSurfaceVariant: palette.muted,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? AppColors.inkDark : AppColors.inkLight,
      onInverseSurface: isDark ? AppColors.bgDark : AppColors.bgLight,
      inversePrimary: isDark ? AppColors.primary : AppColors.primaryBright,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      hintColor: palette.muted,
      dividerColor: outline,
      fontFamilyFallback: AppTextStyles.fontFallback,
    );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[palette],
      textTheme: base.textTheme.apply(
        bodyColor: palette.ink,
        displayColor: palette.ink,
        fontFamilyFallback: AppTextStyles.fontFallback,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: palette.ink,
          fontFamilyFallback: AppTextStyles.fontFallback,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: palette.muted),
        hintStyle: TextStyle(color: palette.muted.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: palette.expense),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide(color: palette.expense, width: 1.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primary.withOpacity(isDark ? 0.22 : 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
            color: sel ? scheme.primary : palette.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected)
                  ? scheme.primary
                  : palette.muted,
            )),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          side: BorderSide(color: outline, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: palette.ink,
        ),
        showCheckmark: false,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: palette.track,
        circularTrackColor: palette.track,
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: palette.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
      ),
    );
  }
}
