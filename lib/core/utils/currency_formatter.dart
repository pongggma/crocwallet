import 'package:intl/intl.dart';
import '../constants/currency_constants.dart';

class CurrencyFormatter {
  /// ₭5,000,000  |  $350.50  |  +฿1,200.00
  static String format(double amount, String code, {bool signed = false}) {
    final c = CurrencyConstants.byCode(code);
    final f = NumberFormat.decimalPatternDigits(decimalDigits: c.decimals);
    final sign = amount < 0 ? '-' : (signed && amount > 0 ? '+' : '');
    return '$sign${c.symbol}${f.format(amount.abs())}';
  }

  /// ₭12.5M
  static String compact(double amount, String code) {
    final c = CurrencyConstants.byCode(code);
    final sign = amount < 0 ? '-' : '';
    return '$sign${c.symbol}${NumberFormat.compact().format(amount.abs())}';
  }

  static String percent(double progress) => '${(progress * 100).floor()}%';
}
