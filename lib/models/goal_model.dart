import 'dart:math';

class GoalModel {
  final int? id;
  final int walletId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? deadline;
  final bool completed;
  final DateTime? completedAt;

  const GoalModel({
    this.id,
    required this.walletId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.currency,
    this.deadline,
    this.completed = false,
    this.completedAt,
  });

  double get progress => targetAmount <= 0
      ? 0
      : (currentAmount / targetAmount).clamp(0.0, 1.0).toDouble();
  double get remaining => max(0, targetAmount - currentAmount).toDouble();

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'wallet_id': walletId,
        'title': title,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'currency': currency,
        'deadline': deadline?.toIso8601String(),
        'completed': completed ? 1 : 0,
        'completed_at': completedAt?.toIso8601String(),
      };

  factory GoalModel.fromMap(Map<String, Object?> m) => GoalModel(
        id: m['id'] as int?,
        walletId: m['wallet_id'] as int,
        title: m['title'] as String,
        targetAmount: (m['target_amount'] as num).toDouble(),
        currentAmount: (m['current_amount'] as num).toDouble(),
        currency: m['currency'] as String,
        deadline:
            m['deadline'] == null ? null : DateTime.parse(m['deadline'] as String),
        completed: (m['completed'] as int? ?? 0) == 1,
        completedAt: m['completed_at'] == null
            ? null
            : DateTime.parse(m['completed_at'] as String),
      );
}
