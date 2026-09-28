import '../models/transaction_model.dart';
import 'app_database.dart';
import 'goal_dao.dart';

class TransactionDao {
  Future<List<TransactionModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  double _round(double v) => (v * 100).roundToDouble() / 100;

  /// Inserts the transaction, updates the wallet balance and syncs goals
  /// in ONE database transaction so they can never get out of step.
  Future<int> insertAndApply(TransactionModel t) async {
    final db = await AppDatabase.instance.database;
    return db.transaction((txn) async {
      final rows = await txn.query('wallets',
          where: 'id = ?', whereArgs: [t.walletId], limit: 1);
      if (rows.isEmpty) throw Exception('Wallet not found');
      final balance = (rows.first['balance'] as num).toDouble();
      final newBalance = _round(balance + t.signedAmount);
      if (newBalance < 0) throw Exception('Not enough balance in this wallet');

      final id = await txn.insert('transactions', t.toMap()..remove('id'));
      await txn.update('wallets', {'balance': newBalance},
          where: 'id = ?', whereArgs: [t.walletId]);
      await GoalDao.syncForWallet(txn, t.walletId, newBalance);
      return id;
    });
  }

  /// Deletes a transaction and reverses its effect on the wallet.
  Future<void> deleteAndReverse(TransactionModel t) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query('wallets',
          where: 'id = ?', whereArgs: [t.walletId], limit: 1);
      if (rows.isNotEmpty) {
        final balance = (rows.first['balance'] as num).toDouble();
        final newBalance = _round(balance - t.signedAmount);
        if (newBalance < 0) {
          throw Exception('Cannot delete: balance would go below zero');
        }
        await txn.update('wallets', {'balance': newBalance},
            where: 'id = ?', whereArgs: [t.walletId]);
        await GoalDao.syncForWallet(txn, t.walletId, newBalance);
      }
      await txn.delete('transactions', where: 'id = ?', whereArgs: [t.id]);
    });
  }
}
