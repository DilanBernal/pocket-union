import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:pocket_union/features/auth/domain/ports/user_port_local.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/ports/logger_port.dart';
import '../../../../core/utils/app_database.dart';
import '../../../../core/utils/logger_provider.dart';
import '../../../../core/utils/shared_preferences.dart';
import '../../persistence/tables/user_profile_table.dart';

part 'user_dao_local.g.dart';

@Riverpod(keepAlive: true)
Future<UserLocalPort> userLocalPort(Ref ref) async {
  final appDb = await ref.watch(appDatabaseProvider.future);
  final logger = ref.watch(loggerProvider);
  final prefs = await ref.watch(sharedPreferencesWithCacheProvider.future);
  return UserDaoLocal(db: appDb, logger: logger, prefs: prefs);
}

class UserDaoLocal extends UserLocalPort {
  final AppDatabase _db;
  final LoggerPort _logger;
  final SharedPreferencesWithCache _prefs;

  UserDaoLocal({
    required AppDatabase db,
    required LoggerPort logger,
    required SharedPreferencesWithCache prefs,
  }) : _db = db,
       _logger = logger,
       _prefs = prefs;

  @override
  Future<bool> deleteAllUsers() async {
    try {
      await _db.delete(_db.userProfileTable).go();
      _logger.info('All users deleted successfully');
      return true;
    } catch (e) {
      _logger.error('Error deleting all users: $e');
      return false;
    }
  }

  @override
  Future<List<UserEntity>> getByFilter(UserEntity filter) async {
    try {
      var query = _db.select(_db.userProfileTable)
        ..where((tbl) => tbl.isDeleted.equals(false));

      if (filter.id.isNotEmpty) {
        query = query..where((tbl) => tbl.id.equals(filter.id));
      }
      if (filter.fullName.isNotEmpty) {
        query = query..where((tbl) => tbl.fullName.equals(filter.fullName));
      }

      final results = await query.map(_mapToEntity).get();
      return results;
    } catch (e, st) {
      _logger.error('Error getting users by filter', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userId = _prefs.getString(PreferencesCacheKeys.userId);
      if (userId == null || userId.isEmpty) return null;
      return getUserById(userId);
    } catch (e, st) {
      _logger.error('Error getting current user', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    try {
      final query = _db.select(_db.userProfileTable)
        ..where((tbl) => tbl.id.equals(id))
        ..limit(1);

      final result = await query.getSingleOrNull();
      return result != null ? _mapToEntity(result) : null;
    } catch (e, st) {
      _logger.error('Error getting user by id: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<bool> upsertUser(UserEntity user) async {
    try {
      user.lastSync = DateTime.now();
      await _db
          .into(_db.userProfileTable)
          .insertOnConflictUpdate(userProfileCompanionFromEntity(user));
      return true;
    } catch (e) {
      _logger.error('Error upserting user: $e');
      return false;
    }
  }

  UserEntity _mapToEntity(UserProfileTableData row) {
    return UserEntity(
      id: row.id,
      fullName: row.fullName ?? '',
      balance: row.userBalance,
      inCloud: row.inCloud,
      avatarUrl: row.avatarUrl,
      lastSync: row.lastSync,
    );
  }
}
