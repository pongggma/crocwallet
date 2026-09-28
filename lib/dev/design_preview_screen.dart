import 'package:flutter/material.dart';
import '../core/constants/category_constants.dart';
import '../core/graphics/croc_avatar.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_tokens.dart';
import '../models/wallet_model.dart';

class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Theme(data: AppTheme.light(), child: const _Panel(title: 'Light')),
          Theme(data: AppTheme.dark(), child: const _Panel(title: 'Dark')),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  const _Panel({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = context.palette;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      child: DefaultTextStyle(
        style: TextStyle(color: palette.ink, fontSize: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: palette.ink)),
            const SizedBox(height: 20),
            _label(palette, 'CROC LEVELS'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final l in CrocLevel.values)
                  _LevelCard(level: l, color: CategoryConstants.walletColors.first),
              ],
            ),
            const SizedBox(height: 24),
            _label(palette, 'WALLET COLOURS'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < CategoryConstants.walletColors.length; i++)
                  CrocAvatar(
                    level: CrocLevel.values[i % 4],
                    color: CategoryConstants.walletColors[i],
                    size: 64,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _label(palette, 'SIZES'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final s in const [32.0, 44.0, 52.0, 72.0, 110.0]) ...[
                  CrocAvatar(
                    level: CrocLevel.strong,
                    color: CategoryConstants.walletColors.first,
                    size: s,
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _label(palette, 'PALETTE'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Swatch('primary', scheme.primary),
                _Swatch('container', scheme.primaryContainer),
                _Swatch('water', palette.water),
                _Swatch('gold', palette.gold),
                _Swatch('income', palette.income),
                _Swatch('expense', palette.expense),
                _Swatch('surface', scheme.surface),
                _Swatch('raised', palette.raised),
                _Swatch('track', palette.track),
                for (var i = 0; i < palette.chart.length; i++)
                  _Swatch('chart ${i + 1}', palette.chart[i]),
              ],
            ),
            const SizedBox(height: 24),
            _label(palette, 'HERO GRADIENT'),
            Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: palette.hero,
                borderRadius: AppRadius.card,
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                '1,250,000 ₭',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(AppPalette p, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: p.muted)),
      );
}

class _LevelCard extends StatelessWidget {
  final CrocLevel level;
  final Color color;
  const _LevelCard({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    return Container(
      width: 156,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: level == CrocLevel.golden ? AppColors.gold : scheme.outlineVariant,
          width: level == CrocLevel.golden ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CrocAvatar(level: level, color: color, size: 110, animate: true),
          ),
          const SizedBox(height: 10),
          Text(level.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          Text(level.subtitle, style: TextStyle(fontSize: 12, color: palette.muted)),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  const _Swatch(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: palette.muted.withOpacity(0.25)),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 10.5, color: palette.muted)),
        ],
      ),
    );
  }
}
