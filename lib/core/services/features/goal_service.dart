import 'package:pocket_union/domain/models/goal.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_goal_port.dart';
import 'package:pocket_union/domain/port/local/goal_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalService implements IGoalPort {
  final GoalLocalPort _goalDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  GoalService(this._goalDao, this._supabaseClient, this._logger);

  @override
  Future<List<Goal>> getAllGoals() async {
    return await _goalDao.getAllGoals();
  }

  @override
  Future<String> createGoal(Goal goal) async {
    final id = await _goalDao.createGoal(goal);

    try {
      await _supabaseClient.from('goal').insert(goal.toJson());
    } catch (e) {
      _logger.error(
        'GoalService: no se pudo sincronizar con Supabase',
        error: e,
      );
    }

    return id;
  }

  @override
  Future<bool> updateGoal(Goal goal) async {
    final updated = await _goalDao.updateGoal(goal);

    try {
      await _supabaseClient
          .from('goal')
          .update(goal.toJson())
          .eq('id', goal.id);
    } catch (e) {
      _logger.error('GoalService: no se pudo actualizar en Supabase', error: e);
    }

    return updated;
  }

  @override
  Future<bool> deleteGoal(String id) async {
    final deleted = await _goalDao.deleteGoal(id);

    try {
      await _supabaseClient.from('goal').delete().eq('id', id);
    } catch (e) {
      _logger.error('GoalService: no se pudo eliminar en Supabase', error: e);
    }

    return deleted;
  }
}
