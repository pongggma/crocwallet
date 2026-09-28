import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/utils/currency_formatter.dart';
import '../models/transaction_model.dart';

class SavingCalendar extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Map<int, String> walletNames;
  final String currency;

  const SavingCalendar({
    super.key,
    required this.transactions,
    required this.walletNames,
    required this.currency,
  });

  @override
  State<SavingCalendar> createState() => _SavingCalendarState();
}

class _SavingCalendarState extends State<SavingCalendar> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    final latestThisMonth = widget.transactions
        .where((t) => t.date.year == _month.year && t.date.month == _month.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (latestThisMonth.isNotEmpty) {
      _selected = DateUtils.dateOnly(latestThisMonth.first.date);
    }
  }
  void _changeMonth(int delta) {
    setState(() {
      final next = DateTime(_month.year, _month.month + delta);
      final lastDay = DateUtils.getDaysInMonth(next.year, next.month);
      _month = next;
      _selected = DateTime(next.year, next.month, _selected.day.clamp(1, lastDay).toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final monthTransactions = widget.transactions.where((t) =>
        t.date.year == _month.year && t.date.month == _month.month).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final byDay = <int, List<TransactionModel>>{};
    for (final tx in monthTransactions) {
      byDay.putIfAbsent(tx.date.day, () => []).add(tx);
    }
    final monthNet = monthTransactions.fold<double>(0, (sum, t) => sum + t.signedAmount);
    final savedDays = byDay.entries.where((e) => e.value.any((t) => t.isDeposit)).length;
    final firstOffset = DateTime(_month.year, _month.month, 1).weekday - 1;
    final dayCount = DateUtils.getDaysInMonth(_month.year, _month.month);
    final cellCount = ((firstOffset + dayCount + 6) ~/ 7) * 7;
    final selectedTransactions = widget.transactions.where((t) =>
        t.date.year == _selected.year &&
        t.date.month == _selected.month &&
        t.date.day == _selected.day).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final selectedDeposits = selectedTransactions
        .where((t) => t.isDeposit)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final selectedWithdrawals = selectedTransactions
        .where((t) => !t.isDeposit)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final currency = widget.currency;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 18, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.calendar_month_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Savings calendar', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  Text('$savedDays saving ${savedDays == 1 ? 'day' : 'days'} this month',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ]),
              ),
              IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded), visualDensity: VisualDensity.compact),
              Text(DateFormat('MMM yyyy').format(_month), style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
              IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right_rounded), visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryPill(context, Icons.south_west_rounded, 'Saved', CurrencyFormatter.compact(monthTransactions.where((t) => t.isDeposit).fold<double>(0, (a, t) => a + t.amount), currency), scheme.primary),
              const SizedBox(width: 8),
              _summaryPill(context, Icons.north_east_rounded, 'Net', CurrencyFormatter.compact(monthNet, currency), monthNet >= 0 ? scheme.tertiary : scheme.error),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Expanded(child: Center(child: Text(d, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700))))]),
          const SizedBox(height: 7),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cellCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 43),
            itemBuilder: (context, index) {
              final day = index - firstOffset + 1;
              if (day < 1 || day > dayCount) return const SizedBox.shrink();
              final date = DateTime(_month.year, _month.month, day);
              final dayTx = byDay[day] ?? const <TransactionModel>[];
              final hasDeposit = dayTx.any((t) => t.isDeposit);
              final hasWithdraw = dayTx.any((t) => !t.isDeposit);
              final selected = DateUtils.isSameDay(date, _selected);
              return Padding(
                padding: const EdgeInsets.all(2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => setState(() => _selected = date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? scheme.primary : (hasDeposit ? scheme.primary.withOpacity(0.08) : Colors.transparent),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('$day', style: theme.textTheme.bodySmall?.copyWith(fontWeight: selected || hasDeposit ? FontWeight.w800 : FontWeight.w500, color: selected ? scheme.onPrimary : scheme.onSurface)),
                      const SizedBox(height: 2),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        if (hasDeposit) _dot(selected ? scheme.onPrimary : scheme.primary),
                        if (hasDeposit && hasWithdraw) const SizedBox(width: 3),
                        if (hasWithdraw) _dot(selected ? scheme.onPrimary.withOpacity(0.65) : scheme.error),
                      ]),
                    ]),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withOpacity(0.45), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(DateFormat('EEE, d MMM').format(_selected), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                if (selectedDeposits > 0) Text('+${CurrencyFormatter.compact(selectedDeposits, currency)}', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800)),
                if (selectedWithdrawals > 0) ...[
                  if (selectedDeposits > 0) const SizedBox(width: 8),
                  Text('−${CurrencyFormatter.compact(selectedWithdrawals, currency)}', style: TextStyle(color: scheme.error, fontWeight: FontWeight.w800)),
                ],
              ]),
              if (selectedTransactions.isEmpty)
                Padding(padding: const EdgeInsets.only(top: 6), child: Text('A quiet day. Pick a day you saved to see it here.', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)))
              else ...[
                const SizedBox(height: 8),
                for (final tx in selectedTransactions.take(3))
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(children: [
                      Icon(tx.isDeposit ? Icons.add_circle_rounded : Icons.remove_circle_rounded, size: 17, color: tx.isDeposit ? scheme.primary : scheme.error),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(tx.note.isEmpty ? (tx.isDeposit ? 'Saved money' : 'Withdrawal') : tx.note,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                          if (widget.walletNames[tx.walletId] != null)
                            Text(widget.walletNames[tx.walletId]!,
                                style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                        ]),
                      ),
                      Text(CurrencyFormatter.format(tx.signedAmount, tx.currency, signed: true), style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: tx.isDeposit ? scheme.primary : scheme.error)),
                    ]),
                  ),
                if (selectedTransactions.length > 3)
                  Padding(padding: const EdgeInsets.only(top: 6), child: Text('+ ${selectedTransactions.length - 3} more entries', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant))),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(BuildContext context, IconData icon, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text('$label ', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: color))),
        ]),
      ),
    );
  }

  Widget _dot(Color color) => Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
