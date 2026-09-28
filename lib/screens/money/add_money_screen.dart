import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/currency_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/goal_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../services/exchange_rate_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../wallets/add_wallet_screen.dart';

class AddMoneyScreen extends StatefulWidget {
  final int? walletId;
  final TransactionType type;
  const AddMoneyScreen({
    super.key,
    this.walletId,
    this.type = TransactionType.deposit,
  });

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late TransactionType _type = widget.type;
  int? _walletId;
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _sourceCurrency;
  ExchangeRates? _rates;
  bool _ratesLoading = false;
  int? _locationId;
  bool _locationInitialized = false;
  bool _showMoreOptions = false;

  @override
  void initState() {
    super.initState();
    _walletId = widget.walletId;
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _ratesLoading = true);
    try {
      final rates = await ExchangeRateService.instance.getRates();
      if (mounted) setState(() => _rates = rates);
    } catch (_) {
      // Same-currency entries remain available offline.
    } finally {
      if (mounted) setState(() => _ratesLoading = false);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (_walletId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a wallet first')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final wallet = context.read<AppState>().walletById(_walletId!);
      if (wallet == null) throw Exception('Wallet not found');
      final entered = Validators.parseAmount(_amount.text)!;
      final sourceCurrency = _sourceCurrency ?? wallet.currency;
      final nativeAmount = sourceCurrency == wallet.currency
          ? entered
          : _rates?.convert(entered, sourceCurrency, wallet.currency);
      if (nativeAmount == null) throw Exception('Exchange rate unavailable. Try again later.');
      final res = await context.read<AppState>().addTransaction(
            walletId: _walletId!,
            type: _type,
            amount: nativeAmount,
            note: _note.text.trim(),
            date: _date,
            sourceAmount: sourceCurrency == wallet.currency ? null : entered,
            sourceCurrency: sourceCurrency == wallet.currency ? null : sourceCurrency,
            exchangeRate: sourceCurrency == wallet.currency ? null : nativeAmount / entered,
          );
      if (wallet.locationId != _locationId) {
        await context.read<AppState>().updateWalletLocation(_walletId!, _locationId);
      }
      if (!mounted) return;
      if (res.completedGoals.isNotEmpty) {
        await showGoalCompleteDialog(context, res.completedGoals.first);
      }
      if (!mounted) return;
      Navigator.pop(context);
      if (res.newAchievements.isNotEmpty) {
        final a = res.newAchievements.first;
        messenger.showSnackBar(
            SnackBar(content: Text('Achievement unlocked: ${a.title}')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.wallets.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Money')),
        body: EmptyState(
          title: 'Create a crocodile first',
          actionLabel: 'Create Crocodile',
          onAction: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AddWalletScreen())),
        ),
      );
    }

    final wallet = s.walletById(_walletId);
    if (!_locationInitialized && wallet != null) {
      _locationId = wallet.locationId;
      _locationInitialized = true;
    }
    final inputCode = _sourceCurrency ?? wallet?.currency ?? 'LAK';
    final inputCur = CurrencyConstants.byCode(inputCode);
    final enteredAmount = Validators.parseAmount(_amount.text);
    final convertedAmount = enteredAmount == null || wallet == null
        ? null
        : inputCode == wallet.currency
            ? enteredAmount
            : _rates?.convert(enteredAmount, inputCode, wallet.currency);
    final isDeposit = _type == TransactionType.deposit;

    return Scaffold(
      appBar: AppBar(title: Text(isDeposit ? 'Add Money' : 'Withdraw')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                    value: TransactionType.deposit,
                    icon: Icon(Icons.add),
                    label: Text('Deposit')),
                ButtonSegment(
                    value: TransactionType.withdraw,
                    icon: Icon(Icons.remove),
                    label: Text('Withdraw')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 20),
            _label('Wallet'),
            DropdownButtonFormField<int>(
              value: _walletId,
              hint: const Text('Choose a wallet'),
              decoration: const InputDecoration(),
              items: [
                for (final w in s.wallets)
                  DropdownMenuItem(
                    value: w.id,
                    child: Text(
                        '${w.name} · ${CurrencyFormatter.format(w.balance, w.currency)}'),
                  ),
              ],
              onChanged: (v) => setState(() {
                _walletId = v;
                _sourceCurrency = null;
                _locationId = s.walletById(v)?.locationId;
                _locationInitialized = true;
              }),
            ),
            if (wallet != null) ...[
              const SizedBox(height: 12),
              _label('Where is this money kept?'),
              DropdownButtonFormField<int?>(
                value: _locationId,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.place_outlined)),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Not set')),
                  for (final location in s.locations)
                    DropdownMenuItem<int?>(
                      value: location.id,
                      child: Text('${location.name} · ${location.type}'),
                    ),
                ],
                onChanged: (value) => setState(() => _locationId = value),
              ),
            ],
            const SizedBox(height: 16),
            _label('Amount'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    value: inputCode,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: [
                      for (final c in CurrencyConstants.all)
                        DropdownMenuItem(value: c.code, child: Text(c.code)),
                    ],
                    onChanged: (v) => setState(() => _sourceCurrency = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 7,
                  child: TextFormField(
                    controller: _amount,
                    autofocus: widget.walletId != null,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      prefixText: '${inputCur.symbol} ',
                      hintText: '0',
                    ),
                    validator: Validators.amount,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            if (wallet != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Icon(Icons.currency_exchange_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(isDeposit ? 'Added to ${wallet.name}' : 'Deducted from ${wallet.name}',
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 3),
                    Text(
                      convertedAmount == null
                          ? (_ratesLoading ? 'Getting exchange rate…' : 'Exchange rate unavailable')
                          : CurrencyFormatter.format(convertedAmount, wallet.currency),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                  ])),
                ]),
              ),
            ],
            const SizedBox(height: 4),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              leading: const Icon(Icons.tune_rounded),
              title: const Text('More details'),
              subtitle: const Text('Optional note or date'),
              initiallyExpanded: _showMoreOptions,
              onExpansionChanged: (expanded) => setState(() => _showMoreOptions = expanded),
              children: [
                Align(alignment: Alignment.centerLeft, child: _label('Date')),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(DateFormatter.date(_date)),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: _label('Note')),
                TextFormField(
                  controller: _note,
                  decoration: const InputDecoration(hintText: 'e.g. Salary'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CustomButton(
              label: isDeposit ? 'Add money' : 'Withdraw',
              onPressed: _saving || convertedAmount == null ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}

Future<void> showGoalCompleteDialog(BuildContext context, GoalModel g) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Icon(Icons.task_alt_rounded, size: 48, color: Theme.of(dialogContext).colorScheme.primary),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('GOAL COMPLETE!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(g.title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.format(g.targetAmount, g.currency),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Icon(Icons.celebration_rounded, size: 28, color: Theme.of(dialogContext).colorScheme.tertiary),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Awesome!'),
        ),
      ],
    ),
  );
}
