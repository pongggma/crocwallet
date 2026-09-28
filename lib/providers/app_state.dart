import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/achievement_model.dart';
import '../models/goal_model.dart';
import '../models/money_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../services/achievement_service.dart';
import '../services/goal_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

class TxResult {
  final List<GoalModel> completedGoals;
  final List<AchievementModel> newAchievements;
  const TxResult(this.completedGoals, this.newAchievements);
}

class AppState extends ChangeNotifier {
  final _walletService = WalletService();
  final _txService = TransactionService();
  final _goalService = GoalService();
  final _achievementService = AchievementService();

  List<WalletModel> wallets = [];
  List<MoneyLocation> locations = [];
  List<TransactionModel> transactions = [];
  List<GoalModel> goals = [];
  ThemeMode themeMode = ThemeMode.system;

  Future<void> load() async {
    final mode = await AppDatabase.instance.getSetting('theme_mode');
    themeMode = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    await _reload();
  }

  Future<void> _reload() async {
    wallets = await _walletService.getWallets();
    locations = await _walletService.getLocations();
    transactions = await _txService.getAll();
    goals = await _goalService.getAll();
    notifyListeners();
  }

  List<AchievementModel> get achievements => _achievementService.evaluate(
      wallets: wallets, transactions: transactions, goals: goals);

  List<String> get activeCurrencies {
    final codes = wallets.map((w) => w.currency).toSet().toList()..sort();
    return codes.isEmpty ? ['LAK'] : codes;
  }

  double totalByCurrency(String code) => wallets
      .where((w) => w.currency == code)
      .fold(0.0, (a, w) => a + w.balance);

  double targetByCurrency(String code) => wallets
      .where((w) => w.currency == code && w.hasTarget)
      .fold(0.0, (a, w) => a + w.targetAmount);

  double savedTowardTargets(String code) => wallets
      .where((w) => w.currency == code && w.hasTarget)
      .fold(0.0, (a, w) => a + w.balance);

  WalletModel? walletById(int? id) {
    for (final w in wallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  GoalModel? goalById(int? id) {
    for (final g in goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  MoneyLocation? locationById(int? id) {
    for (final l in locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  List<TransactionModel> transactionsFor(int walletId) =>
      transactions.where((t) => t.walletId == walletId).toList();

  List<GoalModel> goalsFor(int walletId) =>
      goals.where((g) => g.walletId == walletId).toList();

  List<WalletModel> walletsAt(int locationId) =>
      wallets.where((w) => w.locationId == locationId).toList();

  Map<String, double> totalsAt(int locationId) {
    final out = <String, double>{};
    for (final w in walletsAt(locationId)) {
      out[w.currency] = (out[w.currency] ?? 0) + w.balance;
    }
    return out;
  }

  Future<void> addWallet(WalletModel wallet, {double initialBalance = 0}) async {
    await _walletService.createWallet(wallet, initialBalance: initialBalance);
    await _reload();
  }

  Future<void> deleteWallet(int id) async {
    await _walletService.deleteWallet(id);
    await _reload();
  }

  Future<void> updateWalletLocation(int id, int? locationId) async {
    await _walletService.updateWalletLocation(id, locationId);
    await _reload();
  }

  Future<TxResult> addTransaction({
    required int walletId,
    required TransactionType type,
    required double amount,
    required String note,
    required DateTime date,
    double? sourceAmount,
    String? sourceCurrency,
    double? exchangeRate,
  }) async {
    final wallet = walletById(walletId);
    if (wallet == null) throw Exception('Wallet not found');

    final doneBefore = goals.where((g) => g.completed).map((g) => g.id).toSet();
    final unlockedBefore =
        achievements.where((a) => a.unlocked).map((a) => a.id).toSet();

    await _txService.add(TransactionModel(
      walletId: walletId,
      type: type,
      amount: amount,
      currency: wallet.currency,
      note: note,
      date: date,
      sourceAmount: sourceAmount,
      sourceCurrency: sourceCurrency,
      exchangeRate: exchangeRate,
    ));
    await _reload();

    final newlyDone = goals
        .where((g) => g.completed && !doneBefore.contains(g.id))
        .toList();
    final newAch = achievements
        .where((a) => a.unlocked && !unlockedBefore.contains(a.id))
        .toList();
    return TxResult(newlyDone, newAch);
  }

  Future<void> deleteTransaction(TransactionModel t) async {
    await _txService.delete(t);
    await _reload();
  }

  Future<void> addGoal(GoalModel g) async {
    final wallet = walletById(g.walletId);
    await _goalService.add(GoalModel(
      walletId: g.walletId,
      title: g.title,
      targetAmount: g.targetAmount,
      currentAmount: wallet?.balance ?? 0,
      currency: g.currency,
      deadline: g.deadline,
      completed: (wallet?.balance ?? 0) >= g.targetAmount,
      completedAt: (wallet?.balance ?? 0) >= g.targetAmount ? DateTime.now() : null,
    ));
    await _reload();
  }

  Future<void> deleteGoal(int id) async {
    await _goalService.delete(id);
    await _reload();
  }

  Future<void> addLocation(MoneyLocation l) async {
    await _walletService.addLocation(l);
    await _reload();
  }

  Future<void> deleteLocation(int id) async {
    await _walletService.deleteLocation(id);
    await _reload();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await AppDatabase.instance.setSetting('theme_mode', mode.name);
    notifyListeners();
  }

  Future<String> backupJson() async {
    final data = await AppDatabase.instance.exportAll();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> restoreJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup');
    }
    await AppDatabase.instance.importAll(decoded);
    await _reload();
  }

  Future<void> resetAll() async {
    await AppDatabase.instance.resetAll();
    await _reload();
  }
}
