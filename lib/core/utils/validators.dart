class Validators {
  static double? parseAmount(String? s) =>
      double.tryParse((s ?? '').replaceAll(',', '').trim());

  static String? required(String? v, [String message = 'Required']) =>
      (v == null || v.trim().isEmpty) ? message : null;

  static String? amount(String? v) {
    final n = parseAmount(v);
    if (n == null) return 'Enter a number';
    if (n <= 0) return 'Must be greater than 0';
    return null;
  }

  static String? optionalAmount(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = parseAmount(v);
    if (n == null) return 'Enter a number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }
}
