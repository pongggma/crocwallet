import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';

class MoneyHistoryScreen extends StatefulWidget {
  const MoneyHistoryScreen({super.key});

  @override
  State<MoneyHistoryScreen> createState() => _MoneyHistoryScreenState();
}

class _MoneyHistoryScreenState extends State<MoneyHistoryScreen> {
  TransactionType? _filter; // null = all
  int? _walletId; // null = all

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.transactions
        .where((t) => _filter == null || t.type == _filter)
        .where((t) => _walletId == null || t.walletId == _walletId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    ChoiceChip(
                        label: const Text('All'),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null)),
                    const SizedBox(width: 8),
                    ChoiceChip(
                        label: const Text('Deposits'),
                        selected: _filter == TransactionType.deposit,
                        onSelected: (_) =>
                            setState(() => _filter = TransactionType.deposit)),
                    const SizedBox(width: 8),
                    ChoiceChip(
                        label: const Text('Withdrawals'),
                        selected: _filter == TransactionType.withdraw,
                        onSelected: (_) =>
                            setState(() => _filter = TransactionType.withdraw)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  value: _walletId,
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('All crocodiles')),
                    for (final w in s.wallets)
                      DropdownMenuItem<int?>(value: w.id, child: Text(w.name)),
                  ],
                  onChanged: (v) => setState(() => _walletId = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(icon: Icons.receipt_long_rounded, title: 'No transactions found')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final t = list[i];
                      return Dismissible(
                        key: ValueKey('h_${t.id}'),
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
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      e.toString().replaceFirst('Exception: ', ''))));
                            }
                            return false;
                          }
                        },
                        child: TransactionTile(
                            transaction: t,
                            walletName: s.walletById(t.walletId)?.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
