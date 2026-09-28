import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/goal_progress.dart';
import '../money/add_money_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final int goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final g = s.goalById(goalId);
    if (g == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final wallet = s.walletById(g.walletId);

    return Scaffold(
      appBar: AppBar(
        title: Text(g.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete this goal?'),
                  content: const Text('The crocodile and its money stay untouched.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<AppState>().deleteGoal(goalId);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
              child: Text(g.completed ? '' : (wallet?.emoji ?? ''),
                  style: const TextStyle(fontSize: 72))),
          const SizedBox(height: 12),
          Center(
            child: Text(CurrencyFormatter.percent(g.progress),
                style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: g.completed ? AppColors.gold : null)),
          ),
          const SizedBox(height: 12),
          GoalProgress(progress: g.progress, height: 16),
          const SizedBox(height: 20),
          _row(context, 'Target', CurrencyFormatter.format(g.targetAmount, g.currency)),
          _row(context, 'Saved', CurrencyFormatter.format(g.currentAmount, g.currency)),
          _row(context, 'Remaining', CurrencyFormatter.format(g.remaining, g.currency)),
          _row(context, 'Deadline',
              g.deadline == null ? 'No deadline' : '${DateFormatter.date(g.deadline!)} · ${DateFormatter.deadlineText(g.deadline)}'),
          if (wallet != null) _row(context, 'Crocodile', wallet.name),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              g.completed
                  ? 'Goal complete! Your wallet reached its target.'
                  : 'ອີກ ${CurrencyFormatter.format(g.remaining, g.currency)} ເຈົ້າຈະຮອດເປົ້າໝາຍ!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (!g.completed && wallet != null) ...[
            const SizedBox(height: 20),
            CustomButton(
              label: 'Add Money',
              icon: Icons.add,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddMoneyScreen(walletId: wallet.id))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(color: Theme.of(context).hintColor)),
            Flexible(
                child: Text(v,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
