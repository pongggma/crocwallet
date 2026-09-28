import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/crocodile_card.dart';
import '../../widgets/empty_state.dart';
import 'add_wallet_screen.dart';
import 'wallet_detail_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    void create() => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddWalletScreen()));

    return Scaffold(
      appBar: AppBar(title: const Text('My Wallets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: create,
        icon: const Icon(Icons.add),
        label: const Text('Add Wallet'),
      ),
      body: s.wallets.isEmpty
          ? EmptyState(
              title: 'No wallets yet',
              subtitle: 'Each place you save money = one crocodile wallet.',
              actionLabel: 'Create Wallet',
              onAction: create,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: s.wallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final w = s.wallets[i];
                return CrocodileCard(
                  wallet: w,
                  locationName: s.locationById(w.locationId)?.name,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => WalletDetailScreen(walletId: w.id!))),
                );
              },
            ),
    );
  }
}
