import '../models/money_model.dart';
import 'app_database.dart';

class LocationDao {
  Future<List<MoneyLocation>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('locations', orderBy: 'id ASC');
    return rows.map(MoneyLocation.fromMap).toList();
  }

  Future<int> insert(MoneyLocation l) async {
    final db = await AppDatabase.instance.database;
    return db.insert('locations', l.toMap()..remove('id'));
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }
}
