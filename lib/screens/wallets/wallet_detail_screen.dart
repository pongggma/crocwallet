import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../models/wallet_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/crocodile_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/goal_progress.dart';
import '../../widgets/transaction_tile.dart';
import '../goals/add_goal_screen.dart';
import '../goals/goal_detail_screen.dart';
import '../money/add_money_screen.dart';

class WalletDetailScreen extends StatelessWidget {
  final int walletId;
  const WalletDetailScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final w = s.walletById(walletId);
    if (w == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final level = w.crocodileLevel;
    final txs = s.transactionsFor(walletId);
    final goals = s.goalsFor(walletId);
    final location = s.locationById(w.locationId);
    final color = Color(w.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(w.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v != 'delete') return;
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete this crocodile?'),
                  content: const Text(
                      'Its transactions and goals will be deleted too. This cannot be undone.'),
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
                await context.read<AppState>().deleteWallet(walletId);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete wallet')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Center(child: CrocBadge(emoji: w.emoji, color: color, level: level, boxSize: 110, animate: true)),
          const SizedBox(height: 8),
          Center(
            child: Text('${level.title} · ${level.subtitle}',
                style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(CurrencyFormatter.format(w.balance, w.currency),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
          ),
          if (location != null)
            Center(
              child: Text(location.name,
                  style: TextStyle(color: Theme.of(context).hintColor)),
            ),
          if (w.hasTarget) ...[
            const SizedBox(height: 16),
            GoalProgress(progress: w.progress, color: color, height: 14),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${CurrencyFormatter.percent(w.progress)} of ${CurrencyFormatter.format(w.targetAmount, w.currency)}'),
                if (w.deadline != null) Text(DateFormatter.deadlineText(w.deadline)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              w.progress >= 1
                  ? '${level.message}'
                  : '${level.message}  ອີກ ${CurrencyFormatter.format(w.remaining, w.currency)} ເຈົ້າຈະຮອດເປົ້າໝາຍ!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Add Money',
                  icon: Icons.add,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddMoneyScreen(walletId: walletId))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Withdraw',
                  icon: Icons.remove,
                  outlined: true,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddMoneyScreen(
                              walletId: walletId, type: TransactionType.withdraw))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                  child: Text('Goals',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              TextButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddGoalScreen(walletId: walletId))),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add goal'),
              ),
            ],
          ),
          if (goals.isEmpty)
            Text('No goals for this wallet yet',
                style: TextStyle(color: Theme.of(context).hintColor))
          else
            for (final g in goals)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(g.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: GoalProgress(progress: g.progress, color: color, height: 8),
                ),
                trailing: Text(g.completed ? '' : CurrencyFormatter.percent(g.progress)),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: g.id!))),
              ),
          const SizedBox(height: 16),
          const Text('Transactions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (txs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Nothing here yet — tap Add Money',
                  style: TextStyle(color: Theme.of(context).hintColor)),
            )
          else
            for (final t in txs)
              Dismissible(
                key: ValueKey('tx_${t.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  try {
                    await context.read<AppState>().deleteTransaction(t);
                    return true;
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$e')));
                    }
                    return false;
                  }
                },
                child: TransactionTile(transaction: t),
              ),
        ],
      ),
    );
  }
}
