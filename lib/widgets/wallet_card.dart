import 'package:flutter/material.dart';
import '../core/utils/currency_formatter.dart';
import '../models/wallet_model.dart';
import 'crocodile_card.dart';
import 'goal_progress.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final double? kipEstimate;
  final VoidCallback? onTap;

  const WalletCard({super.key, required this.wallet, this.onTap, this.kipEstimate});

  @override
  Widget build(BuildContext context) {
    final color = Color(wallet.colorValue);
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CrocBadge(
                  emoji: wallet.emoji,
                  color: color,
                  level: wallet.crocodileLevel,
                  boxSize: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wallet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      wallet.hasTarget
                          ? '${CurrencyFormatter.format(wallet.balance, wallet.currency)} / ${CurrencyFormatter.format(wallet.targetAmount, wallet.currency)}'
                          : CurrencyFormatter.format(wallet.balance, wallet.currency),
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                    ),
                    if (kipEstimate != null && wallet.currency != 'LAK')
                      Text('≈ ${CurrencyFormatter.format(kipEstimate!, 'LAK')}',
                          style: TextStyle(color: scheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                    if (wallet.hasTarget) ...[
                      const SizedBox(height: 6),
                      GoalProgress(progress: wallet.progress, color: color, height: 8),
                    ],
                  ],
                ),
              ),
              if (wallet.hasTarget) ...[
                const SizedBox(width: 12),
                Text(CurrencyFormatter.percent(wallet.progress),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
