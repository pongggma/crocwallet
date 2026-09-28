import 'dart:math';

enum CrocLevel { baby, money, strong, golden }

extension CrocLevelX on CrocLevel {
  String get title => switch (this) {
        CrocLevel.baby => 'Baby Croc',
        CrocLevel.money => 'Money Croc',
        CrocLevel.strong => 'Strong Croc',
        CrocLevel.golden => 'Golden Croc',
      };

  String get subtitle => switch (this) {
        CrocLevel.baby => 'ເປົ້າໝາຍນ້ອຍ',
        CrocLevel.money => 'ເກັບເງິນກຳລັງເຕີບໃຫຍ່',
        CrocLevel.strong => 'ເກັບໄດ້ຫຼາຍ',
        CrocLevel.golden => 'ບັນລຸ Goal',
      };

  String get message => switch (this) {
        CrocLevel.baby => 'Every big croc starts small. Keep saving!',
        CrocLevel.money => 'Your croc is growing!',
        CrocLevel.strong => 'Croc is getting stronger!',
        CrocLevel.golden => 'GOAL COMPLETE! ✨',
      };

  double get emojiSize => switch (this) {
        CrocLevel.baby => 26,
        CrocLevel.money => 30,
        CrocLevel.strong => 34,
        CrocLevel.golden => 38,
      };
}

class WalletModel {
  final int? id;
  final String name;
  final String description;
  final int? locationId;
  final String currency;
  final double balance;
  final double targetAmount;
  final DateTime? deadline;
  final DateTime createdAt;
  final String emoji;
  final int colorValue;

  const WalletModel({
    this.id,
    required this.name,
    this.description = '',
    this.locationId,
    required this.currency,
    this.balance = 0,
    this.targetAmount = 0,
    this.deadline,
    required this.createdAt,
    this.emoji = '🐊',
    this.colorValue = 0xFF2E9E6B,
  });

  bool get hasTarget => targetAmount > 0;
  double get progress =>
      hasTarget ? (balance / targetAmount).clamp(0.0, 1.0).toDouble() : 0;
  double get remaining => hasTarget ? max(0, targetAmount - balance).toDouble() : 0;

  CrocLevel get crocodileLevel {
    if (!hasTarget) return balance > 0 ? CrocLevel.money : CrocLevel.baby;
    final p = progress;
    if (p >= 1) return CrocLevel.golden;
    if (p >= 0.6) return CrocLevel.strong;
    if (p >= 0.25) return CrocLevel.money;
    return CrocLevel.baby;
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        'location_id': locationId,
        'currency': currency,
        'balance': balance,
        'target_amount': targetAmount,
        'deadline': deadline?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'emoji': emoji,
        'color': colorValue,
      };

  factory WalletModel.fromMap(Map<String, Object?> m) => WalletModel(
        id: m['id'] as int?,
        name: m['name'] as String,
        description: (m['description'] as String?) ?? '',
        locationId: m['location_id'] as int?,
        currency: m['currency'] as String,
        balance: (m['balance'] as num).toDouble(),
        targetAmount: (m['target_amount'] as num).toDouble(),
        deadline:
            m['deadline'] == null ? null : DateTime.parse(m['deadline'] as String),
        createdAt: DateTime.parse(m['created_at'] as String),
        emoji: (m['emoji'] as String?) ?? '🐊',
        colorValue: (m['color'] as int?) ?? 0xFF2E9E6B,
      );
}
