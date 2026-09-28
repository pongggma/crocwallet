import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7D9C65);
  static const Color primaryDark = Color(0xFF506443);
  static const Color primarySoft = Color(0xFFE6EDD9);
  static const Color primaryBright = Color(0xFFA9C18F);

  static const Color gold = Color(0xFFFF9C4C);
  static const Color goldDeep = Color(0xFF9C4F19);
  static const Color goldSoft = Color(0xFFFFF2A0);
  static const Color water = Color(0xFFFF9C4C);
  static const Color danger = Color(0xFFB93636);
  static const Color success = Color(0xFF7D9C65);

  static const Color bgLight = Color(0xFFF7F8F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color raisedLight = Color(0xFFEEF1E8);
  static const Color outlineLight = Color(0xFFDCE2D4);
  static const Color inkLight = Color(0xFF20271C);
  static const Color mutedLight = Color(0xFF66705F);

  static const Color bgDark = Color(0xFF171B14);
  static const Color cardDark = Color(0xFF22281D);
  static const Color raisedDark = Color(0xFF2B3325);
  static const Color outlineDark = Color(0xFF414B38);
  static const Color inkDark = Color(0xFFF0F3EA);
  static const Color mutedDark = Color(0xFFADB7A1);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF506443), Color(0xFF7D9C65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: [Color(0xFF303D28), Color(0xFF506443)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> chart = [
    Color(0xFF7D9C65),
    Color(0xFFFF9C4C),
    Color(0xFFB93636),
    Color(0xFF9CAB78),
    Color(0xFFE8B76B),
    Color(0xFF697E54),
  ];
}

extension ColorTone on Color {
  Color a(double opacity) => withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0).toDouble())
        .toColor();
  }

  Color darken([double amount = 0.1]) => lighten(-amount);

  Color saturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withSaturation((hsl.saturation + amount).clamp(0.0, 1.0).toDouble())
        .toColor();
  }
}
