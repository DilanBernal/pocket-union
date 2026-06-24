import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:pocket_union/features/auth/domain/ports/user_port_local.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/ports/logger_port.dart';
import '../../../../core/utils/app_database.dart';
import '../../../../core/utils/logger_provider.dart';
import '../../persistence/tables/user_profile_table.dart';

part 'user_dao_local.g.dart';

@Riverpod(keepAlive: true)
Future<UserLocalPort> userLocalPort(Ref ref) async {
  final appDb = await ref.watch(appDatabaseProvider.future);
  final logger = ref.watch(loggerProvider);
  return UserDaoLocal(db: appDb, logger: logger);
}

class UserDaoLocal extends UserLocalPort {
  final AppDatabase _db;
  final LoggerPort _logger;

  UserDaoLocal({required AppDatabase db, required LoggerPort logger})
    : _db = db,
      _logger = logger;

  @override
  Future<bool> deleteAllUsers() {
    // TODO: implement deleteAllUsers
    throw UnimplementedError();
  }

  @override
  Future<List<UserEntity>> getByFilter(UserEntity filter) {
    // TODO: implement getByFilter
    throw UnimplementedError();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<UserEntity?> getUserById(String id) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<bool> upsertUser(UserEntity user) async {
    try {
      user.lastSync = DateTime.now();
      await _db.into(_db.userProfileTable).insertOnConflictUpdate(
        userProfileCompanionFromEntity(user),
      );
      return true;
    } catch (e) {
      _logger.error('Error upserting user: $e');
      return false;
    }
    return false;
  }
}
