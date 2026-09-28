import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/category_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/money_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/money_card.dart';

class MoneyLocationScreen extends StatelessWidget {
  const MoneyLocationScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final name = TextEditingController();
    String type = 'bank';
    final result = await showDialog<MoneyLocation>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('New money location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'BCEL, Cash, LDB...'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in CategoryConstants.locationTypes.entries)
                    ChoiceChip(
                      label: Text(e.key),
                      selected: type == e.key,
                      onSelected: (_) => setLocal(() => type = e.key),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  MoneyLocation(
                    name: name.text.trim(),
                    type: type,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    if (result != null && context.mounted) {
      await context.read<AppState>().addLocation(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, MoneyLocation l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "${l.name}"?'),
        content: const Text('Crocodiles kept here will become "Not set". Money is not deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppState>().deleteLocation(l.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Money Locations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('Add location'),
      ),
      body: s.locations.isEmpty
          ? EmptyState(
              title: 'No locations yet',
              subtitle: 'Add BCEL, Cash, a digital wallet...',
              actionLabel: 'Add location',
              onAction: () => _add(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                for (final l in s.locations) ...[
                  MoneyCard(
                    location: l,
                    totals: s.totalsAt(l.id!),
                    walletCount: s.walletsAt(l.id!).length,
                    onLongPress: () => _confirmDelete(context, l),
                  ),
                  for (final w in s.walletsAt(l.id!))
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 4),
                      child: Text(
                        '↳ ${w.name}  ${CurrencyFormatter.format(w.balance, w.currency)}',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                Text('Long-press a location to delete it.',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
              ],
            ),
    );
  }
}
