import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/expense_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/domain/port/local/expense_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/expense_filter_dto.dart';
import 'package:pocket_union/dto/new_expense_dto.dart';
import 'package:uuid/uuid.dart';

class ExpenseDaoDrift extends ExpenseLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final ExpenseMapper _mapper;
  final Uuid _uuid;

  ExpenseDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    ExpenseMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? ExpenseMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createExpense(NewExpenseDto dto) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final expense = Expense(
      id: id,
      coupleId: dto.coupleId ?? '',
      createdBy: dto.createdBy ?? '',
      name: dto.name,
      transactionDate: dto.transactionDate,
      description: dto.description,
      amount: dto.amount,
      categoryIds: dto.categoryIds,
      isFixed: dto.isFixed,
      importanceLevel: dto.importanceLevel,
      isPlaned: dto.isPlaned,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    await _db.into(_db.expenses).insert(_mapper.toCompanion(expense));
    return id;
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    try {
      final result = await (_db.select(_db.expenses)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('ExpenseDaoDrift: getExpenseById falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final rows = await _db.select(_db.expenses).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('ExpenseDaoDrift: getAllExpenses falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> upsertFromCloud(Expense expense) async {
    try {
      final companion = _mapper.toCompanion(expense);
      await _db.into(_db.expenses).insertOnConflictUpdate(companion);
      return true;
    } catch (e, st) {
      _logger.error('ExpenseDaoDrift: upsertFromCloud falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<List<Expense>> getByFilter(ExpenseFilterDto filter) async {
    try {
      final query = _db.select(_db.expenses);
      query.where((tbl) {
        final predicates = <Expression<bool>>[];
        if (filter.id != null) predicates.add(tbl.id.equals(filter.id!));
        if (filter.coupleId != null) {
          predicates.add(tbl.coupleId.equals(filter.coupleId!));
        }
        if (filter.categoryId != null) {
          predicates.add(tbl.categoryId.equals(filter.categoryId!));
        }
        if (filter.dateFrom != null) {
          predicates.add(tbl.transactionDate.isBiggerOrEqualValue(filter.dateFrom!));
        }
        if (filter.dateTo != null) {
          predicates.add(tbl.transactionDate.isSmallerOrEqualValue(filter.dateTo!));
        }
        if (filter.isFixed != null) {
          predicates.add(tbl.isFixed.equals(filter.isFixed!));
        }
        predicates.add(tbl.isDeleted.equals(false));
        if (predicates.length == 1) return const Constant(true);
        return predicates.reduce((a, b) => a & b);
      });
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('ExpenseDaoDrift: getByFilter falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateExpense(Expense expense) async {
    try {
      await (_db.update(_db.expenses)
            ..where((tbl) => tbl.id.equals(expense.id)))
          .write(_mapper.toCompanion(expense));
      return true;
    } catch (e, st) {
      _logger.error('ExpenseDaoDrift: updateExpense falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteExpense(String id) async {
    try {
      await (_db.update(_db.expenses)
            ..where((tbl) => tbl.id.equals(id)))
          .write(const drift.ExpensesCompanion(
        isDeleted: Value(true),
      ));
      return true;
    } catch (e, st) {
      _logger.error('ExpenseDaoDrift: deleteExpense falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteAllExpenses() async {
    try {
      await _db.delete(_db.expenses).go();
      return true;
    } catch (e, st) {
      _logger.error('ExpenseDaoDrift: deleteAllExpenses falló',
          error: e, stackTrace: st);
      return false;
    }
  }
}
