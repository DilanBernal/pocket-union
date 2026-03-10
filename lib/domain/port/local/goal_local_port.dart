import 'package:pocket_union/domain/models/goal.dart';
import 'package:pocket_union/dto/filter/goal_filter_dto.dart';

abstract class GoalLocalPort {
  Future<String> createGoal(Goal goal);

  Future<Goal?> getGoalById(String id);

  Future<List<Goal>> getAllGoals();

  Future<List<Goal>> getByFilter(GoalFilterDto filter);

  Future<bool> updateGoal(Goal goal);

  Future<bool> deleteGoal(String id);
}
