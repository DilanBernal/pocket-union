import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/recurrent_income_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/recurrent_income.dart';
import 'package:pocket_union/domain/port/local/recurrent_income_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_income_dto.dart';
import 'package:uuid/uuid.dart';

class RecurrentIncomeDaoDrift extends RecurrentIncomeLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final RecurrentIncomeMapper _mapper;
  final Uuid _uuid;

  RecurrentIncomeDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    RecurrentIncomeMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? RecurrentIncomeMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createRecurrentIncome(NewRecurrentIncomeDto dto) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final income = RecurrentIncome(
      id: id,
      coupleId: dto.coupleId,
      name: dto.name,
      amount: dto.amount,
      userRecipientId: dto.userRecipientId,
      recurrentInfo: dto.recurrentInfo,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    await _db.into(_db.recurrentIncomes)
        .insert(_mapper.toCompanion(income));
    return id;
  }

  @override
  Future<RecurrentIncome?> getRecurrentIncomeById(String id) async {
    try {
      final result = await (_db.select(_db.recurrentIncomes)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('RecurrentIncomeDaoDrift: getRecurrentIncomeById falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<RecurrentIncome>> getAllRecurrentIncomes() async {
    try {
      final rows = await _db.select(_db.recurrentIncomes).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('RecurrentIncomeDaoDrift: getAllRecurrentIncomes falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateRecurrentIncome(RecurrentIncome recurrentIncome) async {
    try {
      await (_db.update(_db.recurrentIncomes)
            ..where((tbl) => tbl.id.equals(recurrentIncome.id)))
          .write(_mapper.toCompanion(recurrentIncome));
      return true;
    } catch (e, st) {
      _logger.error('RecurrentIncomeDaoDrift: updateRecurrentIncome falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteRecurrentIncome(String id) async {
    try {
      await (_db.delete(_db.recurrentIncomes)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return true;
    } catch (e, st) {
      _logger.error('RecurrentIncomeDaoDrift: deleteRecurrentIncome falló',
          error: e, stackTrace: st);
      return false;
    }
  }
}
