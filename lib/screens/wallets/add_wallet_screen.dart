import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/category_constants.dart';
import '../../core/constants/currency_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/wallet_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/currency_selector.dart';
import '../../widgets/custom_button.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _purpose = TextEditingController();
  final _target = TextEditingController();
  final _initial = TextEditingController();

  String _currency = 'LAK';
  int? _locationId;
  DateTime? _deadline;

  Color _color = CategoryConstants.walletColors.first;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _purpose.dispose();
    _target.dispose();
    _initial.dispose();
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final target = Validators.parseAmount(_target.text) ?? 0;
    final initial = Validators.parseAmount(_initial.text) ?? 0;
    try {
      await context.read<AppState>().addWallet(
            WalletModel(
              name: _name.text.trim(),
              description: _purpose.text.trim(),
              locationId: _locationId,
              currency: _currency,
              targetAmount: target,
              deadline: target > 0 ? _deadline : null,
              createdAt: DateTime.now(),
              emoji: String.fromCharCode(0x1F40A),
              colorValue: _color.value,
            ),
            initialBalance: initial,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cur = CurrencyConstants.byCode(_currency);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Wallet')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _label('Wallet name'),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(hintText: 'Emergency Fund'),
              validator: (v) => Validators.required(v, 'Give your croc a name'),
            ),
            const SizedBox(height: 16),
            _label('Purpose · ເປົ້າປະສົງ'),
            TextFormField(
              controller: _purpose,
              decoration: const InputDecoration(hintText: 'ເງິນສຳຮອງ'),
            ),
            const SizedBox(height: 16),
            _label('Currency · ສະກຸນເງິນ'),
            CurrencySelector(
                value: _currency, onChanged: (c) => setState(() => _currency = c)),
            const SizedBox(height: 16),
            _label('Where is the money kept?'),
            DropdownButtonFormField<int?>(
              value: _locationId,
              decoration: const InputDecoration(),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Not set')),
                for (final l in s.locations)
                  DropdownMenuItem<int?>(value: l.id, child: Text(l.name)),
              ],
              onChanged: (v) => setState(() => _locationId = v),
            ),
            const SizedBox(height: 16),
            _label('Starting balance (optional)'),
            TextFormField(
              controller: _initial,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: '0'),
              validator: Validators.optionalAmount,
            ),
            const SizedBox(height: 16),
            _label('Target (optional)'),
            TextFormField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(prefixText: '${cur.symbol} ', hintText: '10,000,000'),
              validator: Validators.optionalAmount,
            ),
            const SizedBox(height: 16),
            _label('Deadline (optional)'),
            OutlinedButton.icon(
              onPressed: _pickDeadline,
              icon: const Icon(Icons.event),
              label: Text(_deadline == null
                  ? 'Pick a date'
                  : DateFormatter.date(_deadline!)),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            _label('Wallet color'),
            Wrap(
              spacing: 10,
              children: [
                for (final c in CategoryConstants.walletColors)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: c,
                      child: _color == c
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: _saving ? 'Creating...' : 'Create',
              icon: Icons.check,
              onPressed: _saving ? null : _save,
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
