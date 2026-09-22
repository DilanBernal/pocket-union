import 'package:drift/drift.dart';
import 'package:pocket_union/features/auth/domain/entities/couple_entity.dart';
import 'package:pocket_union/features/auth/domain/enums/couple_usable_state.dart';
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
  Future<bool> deleteCouple(String coupleId) async {
    try {
      // Soft delete: marcar como eliminado en lugar de borrar físicamente
      final updateQuery = _db.update(_db.coupleTable)
        ..where((tbl) => tbl.id.equals(coupleId));

      await updateQuery.write(
        CoupleTableCompanion(
          isDeleted: const Value(true),
          localUpdatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      _logger.info('Couple soft-deleted successfully: $coupleId');
      return true;
    } catch (e, st) {
      _logger.error(
        'Error deleting couple: $coupleId',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<CoupleEntity>> getByFilter(CoupleEntity filter) async {
    try {
      var query = _db.select(_db.coupleTable)
        ..where(
          (tbl) => tbl.isDeleted.equals(false),
        ); // Solo parejas no eliminadas

      // Aplicar filtros dinámicamente según los campos del filter
      if (filter.id.isNotEmpty) {
        query = query..where((tbl) => tbl.id.equals(filter.id));
      }

      if (filter.user1Id != null) {
        query = query..where((tbl) => tbl.user1Id.equals(filter.user1Id!));
      }

      if (filter.user2Id != null) {
        query = query..where((tbl) => tbl.user2Id.equals(filter.user2Id!));
      }

      if (filter.isUsable != CoupleUsableState.waiting) {
        query = query
          ..where((tbl) => tbl.isUsable.equals(filter.isUsable.value));
      }

      final results = await query.map((row) => _mapToEntity(row)).get();

      return results;
    } catch (e, st) {
      _logger.error(
        'Error getting couples by filter',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<CoupleEntity?> getCoupleById(String id) async {
    try {
      final query = _db.select(_db.coupleTable)
        ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false))
        ..limit(1);

      final result = await query
          .map((p0) => _mapToEntity(p0))
          .getSingleOrNull();

      if (result == null) {
        _logger.info('No active couple found with id: $id');
        return null;
      }

      return result;
    } catch (e, st) {
      _logger.error(
        'Error getting couple by id: $id',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<CoupleEntity?> getCoupleByUserId(String userId) async {
    try {
      final query = _db.select(_db.coupleTable)
        ..where(
          (tbl) =>
              (tbl.user1Id.equals(userId) | tbl.user2Id.equals(userId)) &
              tbl.isDeleted.equals(false),
        )
        ..limit(1);

      final result = await query.getSingleOrNull();

      if (result == null) {
        _logger.info('No active couple found for userId: $userId');
        return null;
      }

      return _mapToEntity(result);
    } catch (e, st) {
      _logger.error(
        'Error getting couple by userId: $userId',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<CoupleEntity> joinCoupleByCode(
    String inviteCode,
    String userId,
  ) async {
    // Como no tenemos campo inviteCode, implementamos una lógica alternativa
    // Podrías buscar por userId o generar un código basado en el ID
    try {
      // Buscar pareja activa sin user2Id (disponible para unirse)
      final query = _db.select(_db.coupleTable)
        ..where(
          (tbl) =>
              tbl.user2Id.isNull() &
              tbl.isDeleted.equals(false) &
              tbl.isUsable.equals('WAITING'), // Solo parejas en espera
        )
        ..limit(1);

      final result = await query.getSingleOrNull();

      if (result == null) {
        throw Exception('No available couple found to join');
      }

      final couple = _mapToEntity(result);

      // Verificar que el usuario no sea el mismo que creó la pareja
      if (couple.user1Id == userId) {
        throw Exception('You cannot join your own couple');
      }

      // Actualizar la pareja con el nuevo usuario
      final updatedCouple = couple.copyWith(
        user2Id: userId,
        isUsable: CoupleUsableState.ready,
      );

      await upsertCouple(updatedCouple);

      _logger.info('User $userId joined couple: ${couple.id}');
      return updatedCouple;
    } catch (e, st) {
      _logger.error(
        'Error joining couple with code: $inviteCode',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
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

  CoupleEntity _mapToEntity(CoupleTableData row) {
    return CoupleEntity(
      id: row.id,
      user1Id: row.user1Id,
      user2Id: row.user2Id,
      createdAt: row.createdAt,
      isUsable: CoupleUsableState.fromString(row.isUsable),
    );
  }
}
