import 'package:flutter/material.dart';
import '../core/utils/currency_formatter.dart';
import '../models/money_model.dart';

class MoneyCard extends StatelessWidget {
  final MoneyLocation location;
  final Map<String, double> totals; // currency -> amount
  final int walletCount;
  final VoidCallback? onLongPress;

  const MoneyCard({
    super.key,
    required this.location,
    required this.totals,
    required this.walletCount,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(radius: 23, backgroundColor: scheme.primaryContainer, child: Icon(Icons.account_balance_rounded, color: scheme.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('$walletCount crocodile${walletCount == 1 ? '' : 's'} here',
                        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: totals.isEmpty
                    ? [Text('—', style: TextStyle(color: Theme.of(context).hintColor))]
                    : [
                        for (final e in totals.entries)
                          Text(CurrencyFormatter.format(e.value, e.key),
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
