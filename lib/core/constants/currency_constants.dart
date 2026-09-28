import '../../models/currency_model.dart';

class CurrencyConstants {
  static const List<CurrencyModel> all = [
    CurrencyModel(code: 'LAK', symbol: '₭', name: 'Lao Kip', nameLocal: 'ກີບ', flag: '🇱🇦', decimals: 0),
    CurrencyModel(code: 'THB', symbol: '฿', name: 'Thai Baht', nameLocal: 'ບາດ', flag: '🇹🇭', decimals: 2),
    CurrencyModel(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', nameLocal: 'ຢວນ', flag: '🇨🇳', decimals: 2),
    CurrencyModel(code: 'USD', symbol: '\$', name: 'US Dollar', nameLocal: 'ດອນລາ', flag: '🇺🇸', decimals: 2),
    CurrencyModel(code: 'EUR', symbol: '€', name: 'Euro', nameLocal: 'ເອີໂຣ', flag: '🇪🇺', decimals: 2),
    CurrencyModel(code: 'JPY', symbol: '¥', name: 'Japanese Yen', nameLocal: 'ເຢນ', flag: '🇯🇵', decimals: 0),
    CurrencyModel(code: 'KRW', symbol: '₩', name: 'Korean Won', nameLocal: 'ວອນ', flag: '🇰🇷', decimals: 0),
    CurrencyModel(code: 'VND', symbol: '₫', name: 'Vietnamese Dong', nameLocal: 'ດົງ', flag: '🇻🇳', decimals: 0),
    CurrencyModel(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', nameLocal: 'ດອນລາສິງກະໂປ', flag: '🇸🇬', decimals: 2),
    CurrencyModel(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', nameLocal: 'ດອນລາອົດສະຕຣາລີ', flag: '🇦🇺', decimals: 2),
  ];

  static CurrencyModel byCode(String code) =>
      all.firstWhere((c) => c.code == code, orElse: () => all.first);
}
