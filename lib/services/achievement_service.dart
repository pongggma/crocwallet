import '../models/achievement_model.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class AchievementService {
  List<AchievementModel> evaluate({
    required List<WalletModel> wallets,
    required List<TransactionModel> transactions,
    required List<GoalModel> goals,
  }) {
    final deposits = transactions.where((t) => t.isDeposit).toList();
    final months = deposits.map((t) => '${t.date.year}-${t.date.month}').toSet();
    final currencies = wallets.map((w) => w.currency).toSet();
    final completedGoals = goals.where((g) => g.completed).length;
    final hasStrong = wallets.any((w) =>
        w.crocodileLevel == CrocLevel.strong || w.crocodileLevel == CrocLevel.golden);

    return [
      AchievementModel(
        id: 'first_croc',
        emoji: '🥚',
        title: 'Croc Hatched',
        description: 'Create your first crocodile wallet',
        unlocked: wallets.isNotEmpty,
      ),
      AchievementModel(
        id: 'first_deposit',
        emoji: '💵',
        title: 'First Bite',
        description: 'Add money for the first time',
        unlocked: deposits.isNotEmpty,
      ),
      AchievementModel(
        id: 'ten_deposits',
        emoji: '🔟',
        title: 'Steady Saver',
        description: 'Make 10 deposits',
        unlocked: deposits.length >= 10,
      ),
      AchievementModel(
        id: 'three_months',
        emoji: '📅',
        title: 'Consistent',
        description: 'Save in 3 different months',
        unlocked: months.length >= 3,
      ),
      AchievementModel(
        id: 'multi_currency',
        emoji: '💱',
        title: 'Currency Explorer',
        description: 'Keep wallets in 2 or more currencies',
        unlocked: currencies.length >= 2,
      ),
      AchievementModel(
        id: 'strong_croc',
        emoji: '💪',
        title: 'Strong Croc',
        description: 'Grow a croc to the Strong level (60%)',
        unlocked: hasStrong,
      ),
      AchievementModel(
        id: 'first_goal',
        emoji: '🎯',
        title: 'Goal Getter',
        description: 'Complete your first goal',
        unlocked: completedGoals >= 1,
      ),
      AchievementModel(
        id: 'three_goals',
        emoji: '🏆',
        title: 'Golden Croc',
        description: 'Complete 3 goals',
        unlocked: completedGoals >= 3,
      ),
    ];
  }
}
