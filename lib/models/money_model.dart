/// A place where money is kept (BCEL, JDB, Cash, Digital wallet...).
class MoneyLocation {
  final int? id;
  final String name;
  final String type; // bank | cash | digital | other
  final String emoji;

  const MoneyLocation({
    this.id,
    required this.name,
    this.type = 'bank',
    this.emoji = '🏦',
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'emoji': emoji,
      };

  factory MoneyLocation.fromMap(Map<String, Object?> m) => MoneyLocation(
        id: m['id'] as int?,
        name: m['name'] as String,
        type: (m['type'] as String?) ?? 'bank',
        emoji: (m['emoji'] as String?) ?? '🏦',
      );
}
