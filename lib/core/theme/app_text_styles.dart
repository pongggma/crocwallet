import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const List<String> fontFallback = [
    'Noto Sans Lao',
    'Noto Sans Lao UI',
    'Phetsarath OT',
  ];

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const TextStyle bigMoney = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.1,
    fontFeatures: _tabular,
  );
  static const TextStyle money = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    fontFeatures: _tabular,
  );
  static const TextStyle title = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
  static const TextStyle section = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const TextStyle body = TextStyle(fontSize: 14, height: 1.4);
  static const TextStyle caption = TextStyle(fontSize: 12, height: 1.35);

  static const TextStyle display = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    height: 1.05,
    fontFeatures: _tabular,
  );
  static const TextStyle moneySmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFeatures: _tabular,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
  static const TextStyle chartAxis = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );
}
