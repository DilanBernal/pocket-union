import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/income_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/income_filter_dto.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:uuid/uuid.dart';

class IncomeDaoDrift extends IncomeLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final IncomeMapper _mapper;
  final Uuid _uuid;

  IncomeDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    IncomeMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? IncomeMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createIncome(NewIncomeDto dto) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final income = Income(
      id: id,
      coupleId: dto.coupleId,
      name: dto.name,
      transactionDate: dto.transactionDate ?? now,
      description: dto.description,
      amount: dto.amount,
      categoryIds: dto.categoryIds,
      isRecurring: dto.isRecurring,
      isReceived: dto.isReceived,
      receivedIn: dto.receivedIn as Map<String, dynamic>?,
      createdAt: now,
      userRecipientId: dto.userId,
      syncStatus: SyncStatus.pending,
    );
    await _db.into(_db.incomes).insert(_mapper.toCompanion(income));
    return id;
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    try {
      final result = await (_db.select(_db.incomes)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('IncomeDaoDrift: getIncomeById falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<Income>> getAllIncomes() async {
    try {
      final rows = await _db.select(_db.incomes).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('IncomeDaoDrift: getAllIncomes falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> upsertFromCloud(Income income) async {
    try {
      final companion = _mapper.toCompanion(income);
      await _db.into(_db.incomes).insertOnConflictUpdate(companion);
      return true;
    } catch (e, st) {
      _logger.error('IncomeDaoDrift: upsertFromCloud falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<List<Income>> getByFilter(IncomeFilterDto filter) async {
    try {
      final query = _db.select(_db.incomes);
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
        if (filter.isRecurring != null) {
          predicates.add(tbl.isRecurring.equals(filter.isRecurring!));
        }
        predicates.add(tbl.isDeleted.equals(false));
        if (predicates.length == 1) return const Constant(true);
        return predicates.reduce((a, b) => a & b);
      });
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('IncomeDaoDrift: getByFilter falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateIncome(Income income) async {
    try {
      await (_db.update(_db.incomes)
            ..where((tbl) => tbl.id.equals(income.id)))
          .write(_mapper.toCompanion(income));
      return true;
    } catch (e, st) {
      _logger.error('IncomeDaoDrift: updateIncome falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteIncome(String id) async {
    try {
      await (_db.update(_db.incomes)
            ..where((tbl) => tbl.id.equals(id)))
          .write(const drift.IncomesCompanion(
        isDeleted: Value(true),
      ));
      return true;
    } catch (e, st) {
      _logger.error('IncomeDaoDrift: deleteIncome falló',
          error: e, stackTrace: st);
      return false;
    }
  }
}
