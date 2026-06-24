import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/recurrent_expense_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/recurrent_expense.dart';
import 'package:pocket_union/domain/port/local/recurrent_expense_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_expense_dto.dart';
import 'package:uuid/uuid.dart';

class RecurrentExpenseDaoDrift extends RecurrentExpenseLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final RecurrentExpenseMapper _mapper;
  final Uuid _uuid;

  RecurrentExpenseDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    RecurrentExpenseMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? RecurrentExpenseMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createRecurrentExpense(NewRecurrentExpenseDto dto) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final expense = RecurrentExpense(
      id: id,
      coupleId: dto.coupleId,
      createdBy: dto.createdBy ?? '',
      name: dto.name,
      amount: dto.amount,
      recurrentInfo: dto.recurrentInfo,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    await _db.into(_db.recurrentExpenses)
        .insert(_mapper.toCompanion(expense));
    return id;
  }

  @override
  Future<RecurrentExpense?> getRecurrentExpenseById(String id) async {
    try {
      final result = await (_db.select(_db.recurrentExpenses)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('RecurrentExpenseDaoDrift: getRecurrentExpenseById falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<RecurrentExpense>> getAllRecurrentExpenses() async {
    try {
      final rows = await _db.select(_db.recurrentExpenses).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('RecurrentExpenseDaoDrift: getAllRecurrentExpenses falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateRecurrentExpense(RecurrentExpense recurrentExpense) async {
    try {
      await (_db.update(_db.recurrentExpenses)
            ..where((tbl) => tbl.id.equals(recurrentExpense.id)))
          .write(_mapper.toCompanion(recurrentExpense));
      return true;
    } catch (e, st) {
      _logger.error('RecurrentExpenseDaoDrift: updateRecurrentExpense falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteRecurrentExpense(String id) async {
    try {
      await (_db.delete(_db.recurrentExpenses)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return true;
    } catch (e, st) {
      _logger.error('RecurrentExpenseDaoDrift: deleteRecurrentExpense falló',
          error: e, stackTrace: st);
      return false;
    }
  }
}
