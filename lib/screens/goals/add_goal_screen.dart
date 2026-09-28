import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/currency_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/goal_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../wallets/add_wallet_screen.dart';

class AddGoalScreen extends StatefulWidget {
  final int? walletId;
  const AddGoalScreen({super.key, this.walletId});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _target = TextEditingController();
  int? _walletId;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _walletId = widget.walletId;
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 30),
    );
    if (d != null) setState(() => _deadline = d);
  }

  Future<void> _save() async {
    if (_walletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose which crocodile saves for this goal')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final s = context.read<AppState>();
    final wallet = s.walletById(_walletId)!;
    await s.addGoal(GoalModel(
      walletId: _walletId!,
      title: _title.text.trim(),
      targetAmount: Validators.parseAmount(_target.text)!,
      currency: wallet.currency,
      deadline: _deadline,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.wallets.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Goal')),
        body: EmptyState(
          title: 'Create a crocodile first',
          subtitle: 'A goal is saved inside a crocodile wallet.',
          actionLabel: 'Create Crocodile',
          onAction: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AddWalletScreen())),
        ),
      );
    }
    final wallet = s.walletById(_walletId);
    final cur = wallet == null ? null : CurrencyConstants.byCode(wallet.currency);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const Text('Goal name', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(hintText: ' New Phone'),
              validator: (v) => Validators.required(v, 'Name your goal'),
            ),
            const SizedBox(height: 16),
            const Text('Saved in crocodile', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _walletId,
              hint: const Text('Choose a crocodile'),
              decoration: const InputDecoration(),
              items: [
                for (final w in s.wallets)
                  DropdownMenuItem(
                      value: w.id, child: Text('${w.name} (${w.currency})')),
              ],
              onChanged: (v) => setState(() => _walletId = v),
            ),
            const SizedBox(height: 16),
            const Text('Target', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(prefixText: cur == null ? null : '${cur.symbol} '),
              validator: Validators.amount,
            ),
            const SizedBox(height: 16),
            const Text('Deadline (optional)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _pickDeadline,
              icon: const Icon(Icons.event),
              label: Text(_deadline == null ? 'Pick a date' : DateFormatter.date(_deadline!)),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(label: 'Create Goal', icon: Icons.check, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
