import 'package:flutter/material.dart';

class CategoryConstants {
  static const List<String> depositNotes = [
    'ເງິນເດືອນ · Salary',
    'Bonus',
    'Gift',
    'Business',
    'Other',
  ];

  static const List<String> withdrawNotes = [
    'Emergency',
    'Bought goal item',
    'Transfer',
    'Other',
  ];

  static const Map<String, String> locationTypes = {
    'bank': '🏦',
    'cash': '💵',
    'digital': '💳',
    'other': '📦',
  };

  static const List<String> crocEmojis = ['🐊', '🦎', '🐢', '🐸', '🦖', '💰'];

  static const List<Color> walletColors = [
    Color(0xFF2E9E6B),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
  ];
}
