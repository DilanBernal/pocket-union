import 'package:pocket_union/domain/models/goal_contribution.dart';

abstract class IGoalContributionPort {
  Future<String> createContribution(GoalContribution contribution);

  Future<List<GoalContribution>> getContributionsByGoal(String goalId);

  Future<bool> deleteContribution(String id);
}
