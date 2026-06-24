import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/couple_mapper.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/port/local/couple_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/couple_filter_dto.dart';
import 'package:uuid/uuid.dart';

class CoupleDaoDrift extends CoupleLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final CoupleMapper _mapper;
  final Uuid _uuid;

  CoupleDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    CoupleMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? CoupleMapper(),
        _uuid = const Uuid();

  @override
  Future<Couple> createCouple(String userId, String inviteCode) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final companion = drift.CouplesCompanion.insert(
      id: id,
      user1Id: Value(userId),
      inviteCode: Value(inviteCode),
      isUsable: Value('WAITING'),
      createdAt: Value(now),
      syncStatus: const Value('pending'),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
    await _db.into(_db.couples).insert(companion);
    return Couple(
      id: id,
      createdAt: now,
      user1Id: userId,
      inviteCode: inviteCode,
    );
  }

  @override
  Future<Couple> joinCoupleByCode(String inviteCode, String userId) async {
    final existing = await (_db.select(_db.couples)
          ..where((tbl) => tbl.inviteCode.equals(inviteCode))
          ..limit(1))
        .getSingle();
    final now = DateTime.now().toUtc();
    await (_db.update(_db.couples)
          ..where((tbl) => tbl.id.equals(existing.id)))
        .write(drift.CouplesCompanion(
      user2Id: Value(userId),
      isUsable: const Value('ACTIVE'),
      localUpdatedAt: Value(now),
    ));
    final updated = await (_db.select(_db.couples)
          ..where((tbl) => tbl.id.equals(existing.id)))
        .getSingle();
    return _mapper.toDomain(updated);
  }

  @override
  Future<Couple?> getCoupleById(String id) async {
    try {
      final result = await (_db.select(_db.couples)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('CoupleDaoDrift: getCoupleById falló', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<Couple?> getCoupleByUserId(String userId) async {
    try {
      final result = await (_db.select(_db.couples)
            ..where((tbl) =>
                tbl.user1Id.equals(userId) | tbl.user2Id.equals(userId))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('CoupleDaoDrift: getCoupleByUserId falló', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<Couple?> getCoupleByInviteCode(String inviteCode) async {
    try {
      final result = await (_db.select(_db.couples)
            ..where((tbl) => tbl.inviteCode.equals(inviteCode))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('CoupleDaoDrift: getCoupleByInviteCode falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<Couple>> getByFilter(CoupleFilterDto filter) async {
    try {
      final query = _db.select(_db.couples);
      query.where((tbl) {
        final predicates = <Expression<bool>>[];
        if (filter.id != null) predicates.add(tbl.id.equals(filter.id!));
        if (filter.userId != null) {
          predicates.add(
              tbl.user1Id.equals(filter.userId!) | tbl.user2Id.equals(filter.userId!));
        }
        if (predicates.isEmpty) return const Constant(true);
        return predicates.reduce((a, b) => a & b);
      });
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('CoupleDaoDrift: getByFilter falló', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> upsertCouple(Couple couple) async {
    try {
      final companion = _mapper.toCompanion(couple);
      await _db.into(_db.couples).insertOnConflictUpdate(companion);
      return true;
    } catch (e, st) {
      _logger.error('CoupleDaoDrift: upsertCouple falló', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteCouple(String coupleId) async {
    try {
      await (_db.delete(_db.couples)
            ..where((tbl) => tbl.id.equals(coupleId)))
          .go();
      return true;
    } catch (e, st) {
      _logger.error('CoupleDaoDrift: deleteCouple falló', error: e, stackTrace: st);
      return false;
    }
  }
}
