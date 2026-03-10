import 'package:pocket_union/domain/models/goal.dart';

abstract class IGoalPort {
  Future<String> createGoal(Goal goal);

  Future<List<Goal>> getAllGoals();

  Future<bool> updateGoal(Goal goal);

  Future<bool> deleteGoal(String id);
}
