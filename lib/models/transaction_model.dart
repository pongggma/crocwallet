enum TransactionType { deposit, withdraw }

class TransactionModel {
  final int? id;
  final int walletId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String note;
  final DateTime date;
  final double? sourceAmount;
  final String? sourceCurrency;
  final double? exchangeRate;

  const TransactionModel({
    this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.currency,
    this.note = '',
    required this.date,
    this.sourceAmount,
    this.sourceCurrency,
    this.exchangeRate,
  });

  bool get isDeposit => type == TransactionType.deposit;
  double get signedAmount => isDeposit ? amount : -amount;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'wallet_id': walletId,
        'type': type.name,
        'amount': amount,
        'currency': currency,
        'note': note,
        'date': date.toIso8601String(),
        'source_amount': sourceAmount,
        'source_currency': sourceCurrency,
        'exchange_rate': exchangeRate,
      };

  factory TransactionModel.fromMap(Map<String, Object?> m) => TransactionModel(
        id: m['id'] as int?,
        walletId: m['wallet_id'] as int,
        type: TransactionType.values.byName(m['type'] as String),
        amount: (m['amount'] as num).toDouble(),
        currency: m['currency'] as String,
        note: (m['note'] as String?) ?? '',
        date: DateTime.parse(m['date'] as String),
        sourceAmount: (m['source_amount'] as num?)?.toDouble(),
        sourceCurrency: m['source_currency'] as String?,
        exchangeRate: (m['exchange_rate'] as num?)?.toDouble(),
      );
}
