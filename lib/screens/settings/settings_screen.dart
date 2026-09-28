import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/currency_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/app_state.dart';
import '../../services/exchange_rate_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _backup(BuildContext context) async {
    final json = await context.read<AppState>().backupJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (context.mounted) {
      _snack(context, 'Backup copied to clipboard — paste it into a note or chat to keep it.');
    }
  }

  Future<void> _restore(BuildContext context) async {
    final ctrl = TextEditingController();
    final go = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste your backup text. This REPLACES all current data.'),
            const SizedBox(height: 12),
            TextField(controller: ctrl, maxLines: 6, decoration: const InputDecoration(hintText: '{ "app": "CrocWallet", ... }')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );
    final text = ctrl.text;
    ctrl.dispose();
    if (go != true || !context.mounted) return;
    try {
      await context.read<AppState>().restoreJson(text);
      if (context.mounted) _snack(context, 'Backup restored ');
    } catch (e) {
      if (context.mounted) _snack(context, 'Could not restore: invalid backup');
    }
  }

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text('All crocodiles, transactions and goals will be deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppState>().resetAll();
      if (context.mounted) _snack(context, 'All data reset');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const _Header('Theme'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {s.themeMode},
              onSelectionChanged: (v) => context.read<AppState>().setThemeMode(v.first),
            ),
          ),
          const _Header('Currency'),
          ListTile(
            leading: const Icon(Icons.currency_exchange_rounded),
            title: const Text('Exchange rates'),
            subtitle: const Text('View automatic exchange rates from the API'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ExchangeRateSettingsScreen())),
          ),
          for (final c in CurrencyConstants.all)
            ListTile(
              dense: true,
              leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
              title: Text('${c.code} — ${c.name}'),
              subtitle: Text('${c.nameLocal} · ${c.symbol}'),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Exchange rates update automatically from the API.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const _Header('General'),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            subtitle: Text('Coming soon'),
            enabled: false,
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('English (ລາວ coming soon)'),
            enabled: false,
          ),
          const _Header('Data'),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Backup'),
            subtitle: const Text('Copy all data as text'),
            onTap: () => _backup(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Restore'),
            subtitle: const Text('Paste a backup to restore'),
            onTap: () => _restore(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('Reset Data', style: TextStyle(color: Colors.red)),
            onTap: () => _reset(context),
          ),
          const _Header('About'),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded, size: 24),
            title: const Text(AppConstants.appName),
            subtitle: const Text(AppConstants.tagline),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.account_balance_wallet_rounded, size: 40),
              children: const [
                Text('A savings tracker — not a real investment app. All data stays on your phone.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExchangeRateSettingsScreen extends StatefulWidget {
  const ExchangeRateSettingsScreen({super.key});

  @override
  State<ExchangeRateSettingsScreen> createState() => _ExchangeRateSettingsScreenState();
}

class _ExchangeRateSettingsScreenState extends State<ExchangeRateSettingsScreen> {
  final ExchangeRateService _service = ExchangeRateService.instance;
  ExchangeRates? _rates;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rates = await _service.getRates(forceRefresh: refresh);
      if (!mounted) return;
      setState(() {
        _rates = rates;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load exchange rates. Check your internet connection.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Exchange rates'),
          actions: [
            IconButton(
              tooltip: 'Refresh rates',
              onPressed: _loading ? null : () => _load(refresh: true),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading && _rates == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  if (_rates != null) ...[
                    Text(
                      'Rates update automatically. Last updated ${DateFormatter.date(_rates!.updatedAt)}.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    for (final currency in CurrencyConstants.all)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text(currency.flag, style: const TextStyle(fontSize: 24)),
                        title: Text('1 ${currency.code}'),
                        trailing: Text(
                          currency.code == 'LAK'
                              ? '₭1'
                              : (_rates!.toLak(1, currency.code) == null
                                  ? '—'
                                  : CurrencyFormatter.format(
                                      _rates!.toLak(1, currency.code)!, 'LAK')),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                  if (_loading && _rates != null)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    )),
                  if (_rates == null && !_loading)
                    Center(
                      child: FilledButton.icon(
                        onPressed: () => _load(refresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ),
                ],
              ),
      );
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Theme.of(context).colorScheme.primary)),
      );
}
