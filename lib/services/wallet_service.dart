import '../database/goal_dao.dart';
import '../database/location_dao.dart';
import '../database/transaction_dao.dart';
import '../database/wallet_dao.dart';
import '../models/goal_model.dart';
import '../models/money_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class WalletService {
  final WalletDao _wallets = WalletDao();
  final LocationDao _locations = LocationDao();
  final GoalDao _goals = GoalDao();
  final TransactionDao _transactions = TransactionDao();

  Future<List<WalletModel>> getWallets() => _wallets.getAll();
  Future<List<MoneyLocation>> getLocations() => _locations.getAll();

  /// Creates a wallet. If a target is set, a matching goal is created too.
  /// If [initialBalance] > 0 it is recorded as a first deposit.
  Future<int> createWallet(WalletModel wallet, {double initialBalance = 0}) async {
    final id = await _wallets.insert(wallet);
    if (wallet.hasTarget) {
      await _goals.insert(GoalModel(
        walletId: id,
        title: wallet.name,
        targetAmount: wallet.targetAmount,
        currency: wallet.currency,
        deadline: wallet.deadline,
      ));
    }
    if (initialBalance > 0) {
      await _transactions.insertAndApply(TransactionModel(
        walletId: id,
        type: TransactionType.deposit,
        amount: initialBalance,
        currency: wallet.currency,
        note: 'Initial balance',
        date: DateTime.now(),
      ));
    }
    return id;
  }

  Future<void> deleteWallet(int id) => _wallets.delete(id);
  Future<void> updateWalletLocation(int id, int? locationId) =>
      _wallets.updateLocation(id, locationId);

  Future<int> addLocation(MoneyLocation l) => _locations.insert(l);
  Future<void> deleteLocation(int id) => _locations.delete(id);
}
