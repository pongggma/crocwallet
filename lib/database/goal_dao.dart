import 'package:sqflite/sqflite.dart';
import '../models/goal_model.dart';
import 'app_database.dart';

class GoalDao {
  Future<List<GoalModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('goals', orderBy: 'id DESC');
    return rows.map(GoalModel.fromMap).toList();
  }

  Future<int> insert(GoalModel g) async {
    final db = await AppDatabase.instance.database;
    return db.insert('goals', g.toMap()..remove('id'));
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  /// Keeps every goal of a wallet in sync with the wallet balance.
  /// Works inside a running sqflite transaction.
  static Future<void> syncForWallet(
      DatabaseExecutor db, int walletId, double balance) async {
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate('''
      UPDATE goals SET
        current_amount = ?,
        completed = CASE WHEN ? >= target_amount THEN 1 ELSE 0 END,
        completed_at = CASE WHEN ? >= target_amount
                            THEN COALESCE(completed_at, ?) ELSE NULL END
      WHERE wallet_id = ?''', [balance, balance, balance, now, walletId]);
  }
}
