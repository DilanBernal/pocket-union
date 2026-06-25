import 'package:drift/drift.dart';
import 'package:pocket_union/features/auth/domain/entities/couple_entity.dart';
import 'package:pocket_union/features/auth/domain/ports/couple_port_local.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  CoupleDaoLocal({required AppDatabase db, required LoggerPort logger})
    : _db = db,
      _logger = logger;

  @override
  Future<CoupleEntity> createCouple(String userId, String inviteCode) async {
    try {} catch (e) {
      _logger.error('Error creating couple: $e');
      rethrow;
    }
    // TODO: implement createCouple
    throw UnimplementedError();
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
  Future<CoupleEntity?> getCoupleByUserId(String userId) {
    // TODO: implement getCoupleByUserId
    throw UnimplementedError();
  }

  @override
  Future<CoupleEntity> joinCoupleByCode(String inviteCode, String userId) {
    // TODO: implement joinCoupleByCode
    throw UnimplementedError();
  }

  @override
  Future<bool> upsertCouple(CoupleEntity couple) {
    // TODO: implement upsertCouple
    throw UnimplementedError();
  }
}
