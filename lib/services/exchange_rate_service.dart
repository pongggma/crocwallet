import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/app_database.dart';

class ExchangeRates {
  final Map<String, double> ratesFromLak;
  final DateTime updatedAt;
  final DateTime nextUpdate;

  const ExchangeRates({
    required this.ratesFromLak,
    required this.updatedAt,
    required this.nextUpdate,
  });

  /// Converts a foreign-currency amount to LAK using the API's LAK base rates.
  double? toLak(double amount, String currency) {
    if (currency == 'LAK') return amount;
    final foreignUnitsPerLak = ratesFromLak[currency];
    if (foreignUnitsPerLak == null || foreignUnitsPerLak <= 0) return null;
    return amount / foreignUnitsPerLak;
  }

  /// Converts an amount between currencies using LAK as the common base.
  double? convert(double amount, String from, String to) {
    if (from == to) return amount;
    final lak = toLak(amount, from);
    if (lak == null) return null;
    if (to == 'LAK') return lak;
    final unitsPerLak = ratesFromLak[to];
    if (unitsPerLak == null || unitsPerLak <= 0) return null;
    return lak * unitsPerLak;
  }

  Map<String, Object?> toJson() => {
        'rates': ratesFromLak,
        'updated_at': updatedAt.toIso8601String(),
        'next_update': nextUpdate.toIso8601String(),
      };

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'];
    if (rawRates is! Map) throw const FormatException('Invalid cached rates');
    final rates = <String, double>{};
    for (final entry in rawRates.entries) {
      if (entry.key is String && entry.value is num) {
        rates[entry.key as String] = (entry.value as num).toDouble();
      }
    }
    final updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');
    final nextUpdate = DateTime.tryParse(json['next_update'] as String? ?? '');
    if (rates.isEmpty || updatedAt == null || nextUpdate == null) {
      throw const FormatException('Invalid cached rates');
    }
    return ExchangeRates(
      ratesFromLak: rates,
      updatedAt: updatedAt,
      nextUpdate: nextUpdate,
    );
  }
}

class ExchangeRateService {
  ExchangeRateService._();
  static final ExchangeRateService instance = ExchangeRateService._();

  static const _cacheKey = 'exchange_rates_lak_v1';
  static final _endpoint = Uri.https('open.er-api.com', '/v6/latest/LAK');
  Future<ExchangeRates>? _pending;

  Future<ExchangeRates> getRates({bool forceRefresh = false}) async {
    final cached = await _readCache();
    if (!forceRefresh && cached != null && DateTime.now().isBefore(cached.nextUpdate)) {
      return cached;
    }
    return _pending ??= _fetch(cached).whenComplete(() => _pending = null);
  }

  Future<ExchangeRates?> _readCache() async {
    try {
      final value = await AppDatabase.instance.getSetting(_cacheKey);
      if (value == null) return null;
      return ExchangeRates.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<ExchangeRates> _fetch(ExchangeRates? staleCache) async {
    try {
      final response = await http.get(_endpoint).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('Exchange-rate service returned ${response.statusCode}');
      }
      final payload = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (payload['result'] != 'success' || payload['base_code'] != 'LAK') {
        throw const FormatException('Exchange-rate service returned invalid data');
      }
      final rawRates = payload['rates'];
      if (rawRates is! Map<String, dynamic>) {
        throw const FormatException('Exchange rates are missing');
      }
      final rates = <String, double>{};
      for (final entry in rawRates.entries) {
        if (entry.value is num) rates[entry.key] = (entry.value as num).toDouble();
      }
      final updatedAt = DateTime.fromMillisecondsSinceEpoch(
        (payload['time_last_update_unix'] as num).toInt() * 1000,
        isUtc: true,
      ).toLocal();
      final nextUpdate = DateTime.fromMillisecondsSinceEpoch(
        (payload['time_next_update_unix'] as num).toInt() * 1000,
        isUtc: true,
      ).toLocal();
      final result = ExchangeRates(
        ratesFromLak: rates,
        updatedAt: updatedAt,
        nextUpdate: nextUpdate,
      );
      await AppDatabase.instance.setSetting(_cacheKey, jsonEncode(result.toJson()));
      return result;
    } catch (_) {
      if (staleCache != null) return staleCache;
      rethrow;
    }
  }
}
