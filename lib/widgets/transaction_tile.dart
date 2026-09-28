import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String? walletName;

  const TransactionTile({super.key, required this.transaction, this.walletName});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color = t.isDeposit ? AppColors.success : AppColors.danger;
    final title = t.note.isEmpty ? (t.isDeposit ? 'Deposit' : 'Withdraw') : t.note;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(t.isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            color: color, size: 20),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (walletName != null) walletName!,
          DateFormatter.date(t.date),
          if (t.sourceAmount != null && t.sourceCurrency != null && t.sourceCurrency != t.currency)
            '${CurrencyFormatter.format(t.sourceAmount!, t.sourceCurrency!)} → ${CurrencyFormatter.format(t.amount, t.currency)}',
        ].join(' · '),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        CurrencyFormatter.format(t.signedAmount, t.currency, signed: true),
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15),
      ),
    );
  }
}
