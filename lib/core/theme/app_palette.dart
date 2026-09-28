import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic colours that do not fit in Material's ColorScheme.
/// Read with `context.palette`. Painters should receive these as arguments
/// instead of reading them, so they stay easy to test.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color income;
  final Color expense;
  final Color gold;
  final Color goldSoft;
  final Color water;
  final Color raised; // slightly sunken/raised block inside a card
  final Color track; // empty part of rings, bars and graphs
  final Color muted; // secondary text
  final Color ink; // primary text
  final Gradient hero;
  final List<Color> chart;

  const AppPalette({
    required this.income,
    required this.expense,
    required this.gold,
    required this.goldSoft,
    required this.water,
    required this.raised,
    required this.track,
    required this.muted,
    required this.ink,
    required this.hero,
    required this.chart,
  });

  static const AppPalette light = AppPalette(
    income: AppColors.primary,
    expense: AppColors.danger,
    gold: AppColors.gold,
    goldSoft: AppColors.goldSoft,
    water: AppColors.water,
    raised: AppColors.raisedLight,
    track: Color(0xFFE3E8DC),
    muted: AppColors.mutedLight,
    ink: AppColors.inkLight,
    hero: AppColors.headerGradient,
    chart: AppColors.chart,
  );

  static const AppPalette dark = AppPalette(
    income: AppColors.primaryBright,
    expense: Color(0xFFE47676),
    gold: Color(0xFFFF9C4C),
    goldSoft: Color(0xFF51462A),
    water: Color(0xFFFFB06F),
    raised: AppColors.raisedDark,
    track: Color(0xFF35402E),
    muted: AppColors.mutedDark,
    ink: AppColors.inkDark,
    hero: AppColors.headerGradientDark,
    chart: [
      Color(0xFFA9C18F),
      Color(0xFFFFB06F),
      Color(0xFFE47676),
      Color(0xFF80936C),
      Color(0xFFE2C982),
      Color(0xFF697E54),
    ],
  );

  @override
  AppPalette copyWith({
    Color? income,
    Color? expense,
    Color? gold,
    Color? goldSoft,
    Color? water,
    Color? raised,
    Color? track,
    Color? muted,
    Color? ink,
    Gradient? hero,
    List<Color>? chart,
  }) =>
      AppPalette(
        income: income ?? this.income,
        expense: expense ?? this.expense,
        gold: gold ?? this.gold,
        goldSoft: goldSoft ?? this.goldSoft,
        water: water ?? this.water,
        raised: raised ?? this.raised,
        track: track ?? this.track,
        muted: muted ?? this.muted,
        ink: ink ?? this.ink,
        hero: hero ?? this.hero,
        chart: chart ?? this.chart,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      water: Color.lerp(water, other.water, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      track: Color.lerp(track, other.track, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      hero: t < 0.5 ? hero : other.hero,
      chart: t < 0.5 ? chart : other.chart,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
