class CurrencyModel {
  final String code;
  final String symbol;
  final String name;
  final String nameLocal;
  final String flag;
  final int decimals;

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
    required this.nameLocal,
    required this.flag,
    required this.decimals,
  });
}
