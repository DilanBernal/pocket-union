import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart';
import 'package:pocket_union/core/providers/data_drift_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/domain/models/auth/user.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/user_filter_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_dao_sqlite.g.dart';

@riverpod
UserLocalPort userDao(Ref ref) {
  final appDatabase = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return UserDaoSqlite(appDatabase: appDatabase, logger: logger);
}

class UserDaoSqlite extends UserLocalPort {
  final AppDatabase _db;
  final LoggerPort _logger;

  UserDaoSqlite({required AppDatabase appDatabase, required LoggerPort logger})
      : _db = appDatabase,
        _logger = logger;

  @override
  Future<bool> upsertUser(DomainUser user) async {
    try {
      final now = DateTime.now().toUtc();
      final companion = ProfilesCompanion.insert(
        id: user.id,
        fullName: Value(user.fullName),
        avatarUrl: Value(user.avatarUrl),
        userBalance: Value(user.balance),
        inCloud: Value(user.inCloud),
        updatedAt: Value(now),
        lastSync: Value(user.lastSync),
        syncStatus: const Value('synced'),
        localUpdatedAt: Value(now),
        isDeleted: const Value(false),
      );

      await _db.into(_db.profiles).insertOnConflictUpdate(companion);
      return true;
    } catch (e, st) {
      _logger.error('UserDaoSqlite: Error al guardar usuario', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<DomainUser?> getUserById(String id) async {
    try {
      final result = await (_db.select(_db.profiles)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) return null;
      return _toDomainUser(result);
    } catch (e, st) {
      _logger.error('UserDaoSqlite: Error al buscar usuario por id', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<DomainUser?> getCurrentUser() async {
    try {
      final result = await (_db.select(_db.profiles)..limit(1)).getSingleOrNull();

      if (result == null) {
        return null;
      }

      return _toDomainUser(result);
    } catch (e, st) {
      _logger.error('UserDaoSqlite: Error al cargar el usuario', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<DomainUser>> getByFilter(UserFilterDto filter) async {
    try {
      final query = _db.select(_db.profiles);

      query.where((tbl) {
        final predicates = <Expression<bool>>[];

        if (filter.id != null && filter.id!.trim().isNotEmpty) {
          predicates.add(tbl.id.equals(filter.id!.trim()));
        }
        if (filter.fullName != null && filter.fullName!.trim().isNotEmpty) {
          predicates.add(tbl.fullName.like('%${filter.fullName!.trim()}%'));
        }

        if (predicates.isEmpty) {
          return const Constant<bool>(true);
        }

        return predicates.reduce((value, element) => value & element);
      });

      final rows = await query.get();
      return rows.map(_toDomainUser).toList();
    } catch (e, st) {
      _logger.error('UserDaoSqlite: Error al filtrar usuarios', error: e, stackTrace: st);
      return <DomainUser>[];
    }
  }

  @override
  Future<bool> deleteAllUsers() async {
    try {
      await _db.delete(_db.profiles).go();
      return true;
    } catch (e, st) {
      _logger.error('UserDaoSqlite: Error al eliminar usuarios', error: e, stackTrace: st);
      return false;
    }
  }

  DomainUser _toDomainUser(Profile profile) {
    return DomainUser(
      id: profile.id,
      fullName: profile.fullName ?? '',
      balance: profile.userBalance,
      avatarUrl: profile.avatarUrl,
      lastSync: profile.lastSync,
      inCloud: profile.inCloud,
    );
  }
}
