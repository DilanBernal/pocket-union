import 'package:pocket_union/domain/models/goal_contribution.dart';
import 'package:pocket_union/dto/filter/goal_contribution_filter_dto.dart';

abstract class GoalContributionLocalPort {
  Future<String> createContribution(GoalContribution contribution);

  Future<GoalContribution?> getContributionById(String id);

  Future<List<GoalContribution>> getAllContributions();

  Future<List<GoalContribution>> getByFilter(GoalContributionFilterDto filter);

  Future<bool> updateContribution(GoalContribution contribution);

  Future<bool> deleteContribution(String id);
}
