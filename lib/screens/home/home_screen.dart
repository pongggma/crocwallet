import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/app_state.dart';
import '../../services/exchange_rate_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/goal_progress.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/saving_calendar.dart';
import '../achievements/achievements_screen.dart';
import '../money/add_money_screen.dart';
import '../money/money_history_screen.dart';
import '../money/money_location_screen.dart';
import '../wallets/add_wallet_screen.dart';
import '../wallets/wallet_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex) onGoToTab;
  const HomeScreen({super.key, required this.onGoToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currency;
  ExchangeRates? _rates;
  bool _ratesLoading = true;
  String? _ratesError;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _ratesLoading = true;
      _ratesError = null;
    });
    try {
      final rates = await ExchangeRateService.instance.getRates();
      if (!mounted) return;
      setState(() {
        _rates = rates;
        _ratesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ratesLoading = false;
        _ratesError = 'Exchange rate unavailable';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final codes = s.activeCurrencies;
    final cur = codes.contains(_currency) ? _currency! : codes.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CrocWallet'),
        actions: [
          IconButton(
            tooltip: 'Achievements',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AchievementsScreen())),
          ),
        ],
      ),
      floatingActionButton: s.wallets.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddMoneyScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Add Money'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          _header(context, s, cur, codes),
          const SizedBox(height: 16),
          SavingCalendar(
            transactions: s.transactions.where((t) => t.currency == cur).toList(),
            currency: cur,
            walletNames: {for (final w in s.wallets) w.id!: w.name},
          ),
          if (s.wallets.isEmpty) ...[
            const SizedBox(height: 20),
            EmptyState(
              title: 'Start your savings book',
              subtitle: 'Create a wallet to begin tracking your savings.',
              actionLabel: 'Create Wallet',
              onAction: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddWalletScreen())),
            ),
          ] else ...[
            const SizedBox(height: 20),
            _sectionTitle('My Wallets', 'See all', () => widget.onGoToTab(1)),
            const SizedBox(height: 8),
            for (final w in s.wallets.take(4)) ...[
              WalletCard(
                wallet: w,
                kipEstimate: _rates?.toLak(w.balance, w.currency),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WalletDetailScreen(walletId: w.id!))),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            _locationsTile(context, s),
          ],
          const SizedBox(height: 20),
          _sectionTitle('Recent transactions', 'See all', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MoneyHistoryScreen()));
          }),
          if (s.transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No transactions yet',
                  style: TextStyle(color: Theme.of(context).hintColor)),
            )
          else
            for (final t in s.transactions.take(5))
              TransactionTile(
                  transaction: t, walletName: s.walletById(t.walletId)?.name),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, AppState s, String cur, List<String> codes) {
    final total = s.totalByCurrency(cur);
    final target = s.targetByCurrency(cur);
    final saved = s.savedTowardTargets(cur);
    final progress = target > 0 ? (saved / target).clamp(0.0, 1.0).toDouble() : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saved',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.format(total, cur),
              style: const TextStyle(
                  color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Row(children: [
              const Icon(Icons.currency_exchange_rounded, color: Colors.white, size: 19),
              const SizedBox(width: 9),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('All wallets · Kip estimate',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                  if (_rates != null)
                    Text(CurrencyFormatter.format(
                      s.wallets.fold<double>(0, (sum, w) => sum + (_rates!.toLak(w.balance, w.currency) ?? 0)),
                      'LAK',
                    ), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17))
                  else
                    Text(_ratesLoading ? 'Loading exchange rate…' : (_ratesError ?? 'Rate unavailable'),
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              if (_rates == null && !_ratesLoading)
                IconButton(onPressed: _loadRates, icon: const Icon(Icons.refresh_rounded, color: Colors.white), tooltip: 'Retry exchange rate'),
            ]),
          ),
          if (_rates != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async => launchUrl(Uri.parse('https://www.exchangerate-api.com'), mode: LaunchMode.externalApplication),
                child: Text('Rates by ExchangeRate-API · ${DateFormat('d MMM yyyy').format(_rates!.updatedAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10, decoration: TextDecoration.underline)),
              ),
            ),
          ],
          if (codes.length > 1) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final c in codes)
                  GestureDetector(
                    onTap: () => setState(() => _currency = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: c == cur ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: c == cur ? AppColors.primaryDark : Colors.white)),
                    ),
                  ),
              ],
            ),
          ],
          if (target > 0) ...[
            const SizedBox(height: 16),
            GoalProgress(progress: progress, color: Colors.white, height: 10),
            const SizedBox(height: 8),
            Text(
              '${CurrencyFormatter.percent(progress)} of ${CurrencyFormatter.format(target, cur)} goal',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String action, VoidCallback onTap) => Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      );

  Widget _locationsTile(BuildContext context, AppState s) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ListTile(
        leading: const Icon(Icons.account_balance_rounded, size: 28),
        title: const Text('Where is my money?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${s.locations.length} money locations · ຢູ່ໃສແດ່'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MoneyLocationScreen())),
      ),
    );
  }
}
