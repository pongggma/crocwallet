import '../database/goal_dao.dart';
import '../models/goal_model.dart';

class GoalService {
  final GoalDao _dao = GoalDao();

  Future<List<GoalModel>> getAll() => _dao.getAll();
  Future<void> add(GoalModel g) => _dao.insert(g);
  Future<void> delete(int id) => _dao.delete(id);
}
