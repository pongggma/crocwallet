import '../database/transaction_dao.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final TransactionDao _dao = TransactionDao();

  Future<List<TransactionModel>> getAll() => _dao.getAll();
  Future<void> add(TransactionModel t) => _dao.insertAndApply(t);
  Future<void> delete(TransactionModel t) => _dao.deleteAndReverse(t);
}
