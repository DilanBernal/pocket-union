import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/goal_contribution_mapper.dart';
import 'package:pocket_union/domain/models/goal_contribution.dart';
import 'package:pocket_union/domain/port/local/goal_contribution_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/goal_contribution_filter_dto.dart';
import 'package:uuid/uuid.dart';

class GoalContributionDaoDrift extends GoalContributionLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final GoalContributionMapper _mapper;
  final Uuid _uuid;

  GoalContributionDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    GoalContributionMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? GoalContributionMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createContribution(GoalContribution contribution) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newContribution = GoalContribution(
      id: id,
      goalId: contribution.goalId,
      userId: contribution.userId,
      amount: contribution.amount,
      contributionDate: contribution.contributionDate,
      createdAt: now,
      inCloud: false,
    );
    await _db.into(_db.goalContributions)
        .insert(_mapper.toCompanion(newContribution));
    return id;
  }

  @override
  Future<GoalContribution?> getContributionById(String id) async {
    try {
      final result = await (_db.select(_db.goalContributions)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('GoalContributionDaoDrift: getContributionById falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<GoalContribution>> getAllContributions() async {
    try {
      final rows = await _db.select(_db.goalContributions).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('GoalContributionDaoDrift: getAllContributions falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<GoalContribution>> getByFilter(
      GoalContributionFilterDto filter) async {
    try {
      final query = _db.select(_db.goalContributions);
      query.where((tbl) {
        final predicates = <Expression<bool>>[];
        if (filter.id != null) predicates.add(tbl.id.equals(filter.id!));
        if (filter.goalId != null) {
          predicates.add(tbl.goalId.equals(filter.goalId!));
        }
        if (filter.userId != null) {
          predicates.add(tbl.userId.equals(filter.userId!));
        }
        if (predicates.isEmpty) return const Constant(true);
        return predicates.reduce((a, b) => a & b);
      });
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('GoalContributionDaoDrift: getByFilter falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateContribution(GoalContribution contribution) async {
    try {
      await (_db.update(_db.goalContributions)
            ..where((tbl) => tbl.id.equals(contribution.id)))
          .write(_mapper.toCompanion(contribution));
      return true;
    } catch (e, st) {
      _logger.error('GoalContributionDaoDrift: updateContribution falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteContribution(String id) async {
    try {
      await (_db.delete(_db.goalContributions)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return true;
    } catch (e, st) {
      _logger.error('GoalContributionDaoDrift: deleteContribution falló',
          error: e, stackTrace: st);
      return false;
    }
  }
}
