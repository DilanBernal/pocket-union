import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/goal_mapper.dart';
import 'package:pocket_union/domain/models/goal.dart';
import 'package:pocket_union/domain/port/local/goal_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/goal_filter_dto.dart';
import 'package:uuid/uuid.dart';

class GoalDaoDrift extends GoalLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final GoalMapper _mapper;
  final Uuid _uuid;

  GoalDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    GoalMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? GoalMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createGoal(Goal goal) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newGoal = Goal(
      id: id,
      createdAt: goal.createdAt,
      coupleId: goal.coupleId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      deadline: goal.deadline,
      description: goal.description,
      inCloud: false,
    );
    await _db.into(_db.goals).insert(_mapper.toCompanion(newGoal));
    return id;
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      final result = await (_db.select(_db.goals)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('GoalDaoDrift: getGoalById falló', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<Goal>> getAllGoals() async {
    try {
      final rows = await _db.select(_db.goals).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('GoalDaoDrift: getAllGoals falló', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<Goal>> getByFilter(GoalFilterDto filter) async {
    try {
      final query = _db.select(_db.goals);
      query.where((tbl) {
        final predicates = <Expression<bool>>[];
        if (filter.id != null) predicates.add(tbl.id.equals(filter.id!));
        if (filter.coupleId != null) {
          predicates.add(tbl.coupleId.equals(filter.coupleId!));
        }
        if (filter.name != null) {
          predicates.add(tbl.name.like('%${filter.name}%'));
        }
        if (predicates.isEmpty) return const Constant(true);
        return predicates.reduce((a, b) => a & b);
      });
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('GoalDaoDrift: getByFilter falló', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateGoal(Goal goal) async {
    try {
      await (_db.update(_db.goals)
            ..where((tbl) => tbl.id.equals(goal.id)))
          .write(_mapper.toCompanion(goal));
      return true;
    } catch (e, st) {
      _logger.error('GoalDaoDrift: updateGoal falló', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteGoal(String id) async {
    try {
      await (_db.delete(_db.goals)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return true;
    } catch (e, st) {
      _logger.error('GoalDaoDrift: deleteGoal falló', error: e, stackTrace: st);
      return false;
    }
  }
}
