import 'package:flutter/material.dart';
import '../core/constants/currency_constants.dart';

class CurrencySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final List<String>? codes; // null = all supported currencies

  const CurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.codes,
  });

  @override
  Widget build(BuildContext context) {
    final list = CurrencyConstants.all
        .where((c) => codes == null || codes!.contains(c.code))
        .toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in list)
          ChoiceChip(
            label: Text('${c.flag} ${c.code}'),
            selected: c.code == value,
            onSelected: (_) => onChanged(c.code),
          ),
      ],
    );
  }
}
