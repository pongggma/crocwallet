import '../models/wallet_model.dart';
import 'app_database.dart';

class WalletDao {
  Future<List<WalletModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('wallets', orderBy: 'id DESC');
    return rows.map(WalletModel.fromMap).toList();
  }

  Future<WalletModel?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('wallets', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : WalletModel.fromMap(rows.first);
  }

  Future<int> insert(WalletModel w) async {
    final db = await AppDatabase.instance.database;
    return db.insert('wallets', w.toMap()..remove('id'));
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateLocation(int id, int? locationId) async {
    final db = await AppDatabase.instance.database;
    await db.update('wallets', {'location_id': locationId},
        where: 'id = ?', whereArgs: [id]);
  }
}
