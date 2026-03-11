import 'package:pocket_union/domain/models/goal_contribution.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_goal_contribution_port.dart';
import 'package:pocket_union/domain/port/local/goal_contribution_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/goal_contribution_filter_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalContributionService implements IGoalContributionPort {
  final GoalContributionLocalPort _contributionDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  GoalContributionService(
    this._contributionDao,
    this._supabaseClient,
    this._logger,
  );

  @override
  Future<List<GoalContribution>> getContributionsByGoal(String goalId) async {
    return await _contributionDao.getByFilter(
      GoalContributionFilterDto(goalId: goalId),
    );
  }

  @override
  Future<String> createContribution(GoalContribution contribution) async {
    final id = await _contributionDao.createContribution(contribution);

    try {
      await _supabaseClient
          .from('goal_contribution')
          .insert(contribution.toJson());
    } catch (e) {
      _logger.error(
        'GoalContributionService: no se pudo sincronizar con Supabase',
        error: e,
      );
    }

    return id;
  }

  @override
  Future<bool> deleteContribution(String id) async {
    final deleted = await _contributionDao.deleteContribution(id);

    try {
      await _supabaseClient.from('goal_contribution').delete().eq('id', id);
    } catch (e) {
      _logger.error(
        'GoalContributionService: no se pudo eliminar en Supabase',
        error: e,
      );
    }

    return deleted;
  }
}
