import 'package:flutter/material.dart';
import '../core/graphics/croc_avatar.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../models/wallet_model.dart';
import 'goal_progress.dart';

class CrocodileCard extends StatelessWidget {
  final WalletModel wallet;
  final String? locationName;
  final VoidCallback? onTap;

  const CrocodileCard({
    super.key,
    required this.wallet,
    this.locationName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final level = wallet.crocodileLevel;
    final color = Color(wallet.colorValue);
    final golden = level == CrocLevel.golden;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: golden ? AppColors.gold : scheme.outlineVariant,
          width: golden ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CrocBadge(emoji: wallet.emoji, color: color, level: level),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wallet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(
                          locationName ?? (wallet.description.isEmpty ? 'No location' : wallet.description),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (golden ? AppColors.gold : color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(level.title,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: golden ? const Color(0xFFB98600) : color)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(CurrencyFormatter.format(wallet.balance, wallet.currency),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              if (wallet.hasTarget) ...[
                const SizedBox(height: 4),
                Text(
                  'of ${CurrencyFormatter.format(wallet.targetAmount, wallet.currency)}  ·  ${CurrencyFormatter.percent(wallet.progress)}',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                ),
                const SizedBox(height: 10),
                GoalProgress(progress: wallet.progress, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CrocBadge extends StatelessWidget {
  /// Retained for source compatibility; the crocodile is custom-painted.
  final String? emoji;
  final Color color;
  final CrocLevel level;
  final double boxSize;
  final bool animate;

  const CrocBadge({
    super.key,
    this.emoji,
    required this.color,
    required this.level,
    this.boxSize = 52,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) =>
      CrocAvatar(level: level, color: color, size: boxSize, animate: animate);
}
