import 'package:flutter/material.dart';

/// Spacing, radius and shadow tokens shared by every screen and painter.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double huge = 32;

  /// Default horizontal page padding.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: 20);
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get control => BorderRadius.circular(md);
  static BorderRadius get pill => BorderRadius.circular(999);
}

class AppShadows {
  AppShadows._();

  /// Soft ledger-card shadow. Very light in dark mode, where borders do the work.
  static List<BoxShadow> card(Brightness b) => b == Brightness.dark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x147D9C65),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ];
}
