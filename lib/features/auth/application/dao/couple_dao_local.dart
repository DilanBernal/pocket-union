import 'package:drift/drift.dart';
import 'package:pocket_union/features/auth/domain/entities/couple_entity.dart';
import 'package:pocket_union/features/auth/domain/ports/couple_port_local.dart';
import 'package:pocket_union/features/auth/persistence/tables/couple_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/ports/logger_port.dart';
import '../../../../core/utils/app_database.dart';
import '../../../../core/utils/logger_provider.dart';

part 'couple_dao_local.g.dart';

@Riverpod(keepAlive: true)
Future<CouplePortLocal> coupleDaoLocal(Ref ref) async {
  final appDb = await ref.watch(appDatabaseProvider.future);
  final logger = ref.watch(loggerProvider);
  return CoupleDaoLocal(db: appDb, logger: logger);
}

class CoupleDaoLocal implements CouplePortLocal {
  final AppDatabase _db;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  CoupleDaoLocal({required AppDatabase db, required LoggerPort logger})
    : _db = db,
      _logger = logger;

  @override
  Future<CoupleEntity> createCouple(String userId, String inviteCode) async {
    try {
      final couple = CoupleEntity(
        id: _uuid.v4(),
        user1Id: userId,
        createdAt: DateTime.now().toUtc(),
      );
      final coupleCompanion = coupleTableCompanionFromEntity(couple);

      await _db.into(_db.coupleTable).insert(coupleCompanion);
      return couple;
    } catch (e) {
      _logger.error('Error creating couple: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteCouple(String coupleId) {
    // TODO: implement deleteCouple
    throw UnimplementedError();
  }

  @override
  Future<List<CoupleEntity>> getByFilter(CoupleEntity filter) {
    // TODO: implement getByFilter
    throw UnimplementedError();
  }

  @override
  Future<CoupleEntity?> getCoupleById(String id) {
    // TODO: implement getCoupleById
    throw UnimplementedError();
  }

  @override
  Future<CoupleEntity?> getCoupleByInviteCode(String inviteCode) {
    // TODO: implement getCoupleByInviteCode
    throw UnimplementedError();
  }

  @override
  Future<CoupleEntity?> getCoupleByUserId(String userId) async {
    var query = _db.select(_db.coupleTable)
      ..where(
        (tbl) => tbl.user1Id.equals(userId) | (tbl.user2Id.equals(userId)),
      );

    final response = await query.getSingleOrNull();
    if (response == null) {
      _logger.info('No couple found for userId: $userId');
      return null;
    }
    return CoupleEntity.fromMap(response.toJson());
  }

  @override
  Future<CoupleEntity> joinCoupleByCode(String inviteCode, String userId) {
    // TODO: implement joinCoupleByCode
    throw UnimplementedError();
  }

  @override
  Future<bool> upsertCouple(CoupleEntity couple) async {
    try {
      final coupleCompanion = coupleTableCompanionFromEntity(couple);
      await _db.into(_db.coupleTable).insertOnConflictUpdate(coupleCompanion);
      return true;
    } catch (e, st) {
      _logger.error(
        'Error upserting couple: ${couple.id}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
