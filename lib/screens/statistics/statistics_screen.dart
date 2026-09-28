import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/app_state.dart';
import '../../widgets/currency_selector.dart';
import '../../widgets/empty_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _currency;
  bool _yearly = false;
  DateTime _period = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final codes = s.activeCurrencies;
    final cur = codes.contains(_currency) ? _currency! : codes.first;

    if (s.transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const EmptyState(
            icon: Icons.query_stats_rounded,
            title: 'No data yet',
            subtitle: 'Add some money and your stats will appear here.'),
      );
    }

    final txs = s.transactions.where((t) => t.currency == cur).toList();
    final deposited = txs.where((t) => t.isDeposit).fold(0.0, (a, t) => a + t.amount);
    final withdrawn = txs.where((t) => !t.isDeposit).fold(0.0, (a, t) => a + t.amount);

    final now = DateTime.now();
    final periodStart = _yearly
        ? DateTime(_period.year)
        : DateTime(_period.year, _period.month);
    final periodEnd = _yearly
        ? DateTime(_period.year + 1)
        : DateTime(_period.year, _period.month + 1);
    final periodTransactions = txs.where((t) =>
        !t.date.isBefore(periodStart) && t.date.isBefore(periodEnd)).toList();
    final periodDeposited = periodTransactions
        .where((t) => t.isDeposit).fold(0.0, (a, t) => a + t.amount);
    final periodWithdrawn = periodTransactions
        .where((t) => !t.isDeposit).fold(0.0, (a, t) => a + t.amount);
    final periodNet = periodDeposited - periodWithdrawn;
    final periodLabel = _yearly ? '${_period.year}' : DateFormatter.monthYear(_period);

    final months = _yearly
        ? [for (var i = 1; i <= 12; i++) DateTime(_period.year, i, 1)]
        : [for (var i = 5; i >= 0; i--) DateTime(_period.year, _period.month - i, 1)];
    final monthlyNet = <double>[];
    final cumulative = <double>[];
    for (final m in months) {
      final next = DateTime(m.year, m.month + 1, 1);
      monthlyNet.add(txs
          .where((t) => !t.date.isBefore(m) && t.date.isBefore(next))
          .fold(0.0, (a, t) => a + t.signedAmount));
      cumulative.add(txs.where((t) => t.date.isBefore(next)).fold(0.0, (a, t) => a + t.signedAmount));
    }

    final goals = s.goals.where((g) => g.currency == cur).toList();
    final activeGoals = goals.where((g) => !g.completed).length;
    final doneGoals = goals.where((g) => g.completed).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (codes.length > 1) ...[
            CurrencySelector(value: cur, codes: codes, onChanged: (c) => setState(() => _currency = c)),
            const SizedBox(height: 16),
          ],
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Monthly'), icon: Icon(Icons.calendar_view_month)),
              ButtonSegment(value: true, label: Text('Yearly'), icon: Icon(Icons.calendar_month)),
            ],
            selected: {_yearly},
            onSelectionChanged: (v) => setState(() => _yearly = v.first),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: _yearly ? 'Previous year' : 'Previous month',
                onPressed: () => setState(() => _period = _yearly
                    ? DateTime(_period.year - 1, _period.month)
                    : DateTime(_period.year, _period.month - 1)),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(periodLabel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              IconButton(
                tooltip: _yearly ? 'Next year' : 'Next month',
                onPressed: (_yearly ? _period.year < now.year :
                        _period.year < now.year || (_period.year == now.year && _period.month < now.month))
                    ? () => setState(() => _period = _yearly
                        ? DateTime(_period.year + 1, _period.month)
                        : DateTime(_period.year, _period.month + 1))
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$periodLabel report · ${periodTransactions.length} transactions',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _reportValue('Deposits', periodDeposited, cur, AppColors.success)),
                Expanded(child: _reportValue('Withdrawals', periodWithdrawn, cur, AppColors.danger)),
                Expanded(child: _reportValue('Net', periodNet, cur,
                    periodNet >= 0 ? AppColors.success : AppColors.danger)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _stat(context, 'Total saved', CurrencyFormatter.format(deposited, cur), AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _stat(context, 'Total withdrawn', CurrencyFormatter.format(withdrawn, cur), AppColors.danger)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _stat(
                      context,
                      'Period net',
                      CurrencyFormatter.format(periodNet, cur, signed: true),
                      periodNet >= 0 ? AppColors.success : AppColors.danger)),
              const SizedBox(width: 12),
              Expanded(child: _stat(context, 'Active goals', '$activeGoals', null)),
              const SizedBox(width: 12),
              Expanded(child: _stat(context, 'Completed', '$doneGoals', AppColors.gold)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Savings (balance at month end)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LinePainter(
                values: cumulative,
                color: Theme.of(context).colorScheme.primary,
                grid: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final m in months)
                Text(DateFormatter.monthShort(m),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Monthly saving',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _bars(context, months, monthlyNet, cur),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color? color) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _reportValue(String label, double amount, String currency, Color color) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(amount, currency),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      );

  Widget _bars(BuildContext context, List<DateTime> months, List<double> net, String cur) {
    final maxAbs = max(1.0, net.map((v) => v.abs()).reduce(max));
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < months.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.compact(net[i], cur),
                      style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 4),
                  Container(
                    height: max(3.0, net[i].abs() / maxAbs * 100),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: net[i] >= 0 ? AppColors.success : AppColors.danger,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormatter.monthShort(months[i]),
                      style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color grid;
  _LinePainter({required this.values, required this.color, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const pad = 14.0;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = pad + (size.height - 2 * pad) * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final minV = min(0.0, values.reduce(min));
    var maxV = values.reduce(max);
    if (maxV == minV) maxV = minV + 1;

    Offset pt(int i) {
      final x = pad + (size.width - 2 * pad) * i / (values.length - 1);
      final y = size.height - pad - (values[i] - minV) / (maxV - minV) * (size.height - 2 * pad);
      return Offset(x, y);
    }

    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(pt(i).dx, pt(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(pt(i), 5, Paint()..color = color);
      canvas.drawCircle(pt(i), 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.values != values || old.color != color || old.grid != grid;
}
