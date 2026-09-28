import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wallet_model.dart';
import '../../providers/app_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.achievements;
    final unlocked = list.where((a) => a.unlocked).length;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text('$unlocked / ${list.length} unlocked',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final a in list)
            Opacity(
              opacity: a.unlocked ? 1 : 0.45,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(a.unlocked ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded, size: 32, color: a.unlocked ? scheme.primary : scheme.onSurfaceVariant),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text(a.description,
                              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text('Croc levels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final l in CrocLevel.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.account_balance_wallet_rounded, size: 24, color: scheme.primary),
              title: Text(l.title),
              subtitle: Text(l.subtitle),
            ),
        ],
      ),
    );
  }
}
