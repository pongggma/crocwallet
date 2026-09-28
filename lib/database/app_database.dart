import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/app_constants.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  static const List<String> _dataTables = [
    'locations',
    'wallets',
    'transactions',
    'goals',
  ];

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            emoji TEXT NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE wallets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            location_id INTEGER REFERENCES locations(id) ON DELETE SET NULL,
            currency TEXT NOT NULL,
            balance REAL NOT NULL DEFAULT 0,
            target_amount REAL NOT NULL DEFAULT 0,
            deadline TEXT,
            created_at TEXT NOT NULL,
            emoji TEXT,
            color INTEGER
          )''');
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            wallet_id INTEGER NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            currency TEXT NOT NULL,
            note TEXT,
            date TEXT NOT NULL,
            source_amount REAL,
            source_currency TEXT,
            exchange_rate REAL
          )''');
        await db.execute('''
          CREATE TABLE goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            wallet_id INTEGER NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            target_amount REAL NOT NULL,
            current_amount REAL NOT NULL DEFAULT 0,
            currency TEXT NOT NULL,
            deadline TEXT,
            completed INTEGER NOT NULL DEFAULT 0,
            completed_at TEXT
          )''');
        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT
          )''');
        await _seedLocations(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE transactions ADD COLUMN source_amount REAL');
          await db.execute('ALTER TABLE transactions ADD COLUMN source_currency TEXT');
          await db.execute('ALTER TABLE transactions ADD COLUMN exchange_rate REAL');
        }
      },
    );
  }

  Future<void> _seedLocations(DatabaseExecutor db) async {
    const defaults = [
      {'name': 'BCEL', 'type': 'bank', 'emoji': '🏦'},
      {'name': 'JDB', 'type': 'bank', 'emoji': '🏦'},
      {'name': 'Cash', 'type': 'cash', 'emoji': '💵'},
      {'name': 'Digital Wallet', 'type': 'digital', 'emoji': '💳'},
    ];
    for (final l in defaults) {
      await db.insert('locations', l);
    }
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, Object?>> exportAll() async {
    final db = await database;
    final out = <String, Object?>{'app': AppConstants.appName, 'version': AppConstants.dbVersion};
    for (final t in _dataTables) {
      out[t] = await db.query(t);
    }
    return out;
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    if (data['app'] != AppConstants.appName) {
      throw const FormatException('This is not a CrocWallet backup');
    }
    final db = await database;
    await db.transaction((txn) async {
      for (final t in _dataTables.reversed) {
        await txn.delete(t);
      }
      // parents first: locations -> wallets -> transactions/goals
      for (final t in _dataTables) {
        final rows = (data[t] as List?) ?? const [];
        for (final r in rows) {
          await txn.insert(t, Map<String, Object?>.from(r as Map));
        }
      }
    });
  }

  Future<void> resetAll() async {
    final db = await database;
    await db.transaction((txn) async {
      for (final t in _dataTables.reversed) {
        await txn.delete(t);
      }
      await _seedLocations(txn);
    });
  }
}
