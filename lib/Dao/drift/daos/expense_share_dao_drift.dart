import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/expense_share_mapper.dart';
import 'package:pocket_union/domain/models/expense_share.dart';
import 'package:pocket_union/domain/port/local/expense_share_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/expense_share_filter_dto.dart';
import 'package:uuid/uuid.dart';

class ExpenseShareDaoDrift extends ExpenseShareLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final ExpenseShareMapper _mapper;
  final Uuid _uuid;

  ExpenseShareDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    ExpenseShareMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? ExpenseShareMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createExpenseShare(ExpenseShare share) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newShare = ExpenseShare(
      id: id,
      createdAt: now,
      expenseId: share.expenseId,
      userId: share.userId,
      sharePercentage: share.sharePercentage,
      inCloud: false,
    );
    await _db.into(_db.expenseShares).insert(_mapper.toCompanion(newShare));
    return id;
  }

  @override
  Future<ExpenseShare?> getExpenseShareById(String id) async {
    try {
      final result = await (_db.select(_db.expenseShares)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('ExpenseShareDaoDrift: getExpenseShareById falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<ExpenseShare>> getAllExpenseShares() async {
    try {
      final rows = await _db.select(_db.expenseShares).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('ExpenseShareDaoDrift: getAllExpenseShares falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<ExpenseShare>> getByFilter(ExpenseShareFilterDto filter) async {
    try {
      final query = _db.select(_db.expenseShares);
      query.where((tbl) {
        final predicates = <Expression<bool>>[];
        if (filter.id != null) predicates.add(tbl.id.equals(filter.id!));
        if (filter.expenseId != null) {
          predicates.add(tbl.expenseId.equals(filter.expenseId!));
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
      _logger.error('ExpenseShareDaoDrift: getByFilter falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateExpenseShare(ExpenseShare share) async {
    try {
      await (_db.update(_db.expenseShares)
            ..where((tbl) => tbl.id.equals(share.id)))
          .write(_mapper.toCompanion(share));
      return true;
    } catch (e, st) {
      _logger.error('ExpenseShareDaoDrift: updateExpenseShare falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteExpenseShare(String id) async {
    try {
      await (_db.delete(_db.expenseShares)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return true;
    } catch (e, st) {
      _logger.error('ExpenseShareDaoDrift: deleteExpenseShare falló',
          error: e, stackTrace: st);
      return false;
    }
  }
}
