import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/features/auth/application/dao/user_dao_local.dart';
import 'package:uuid/uuid.dart';

import '../mocks/db.mock.dart';
import '../mocks/logger.mock.dart';
import '../mocks/shared_preferences_cache.dart';

void main() {
  final Uuid uuid = const Uuid();
  late AppDatabase db;
  setUp(() {
    db = getMockDatabase();
  });
  tearDown(() async {
    await db.close();
  });
  group('Queries exitosas', () {
    test('Que funcione traer un solo usuario', () async {
      // Arrange
      final id = uuid.v4();
      await db
          .into(db.userProfileTable)
          .insert(
            UserProfileTableData(
              id: id,
              userBalance: 0,
              inCloud: false,
              syncStatus: SyncStatus.pendingCreate.name,
              isDeleted: false,
            ),
          );

      final prefs = MockSharedPreferencesWithCache();
      final logger = MockLogger();
      final userDao = UserDaoLocal(db: db, logger: logger, prefs: prefs);

      // Act
      final result = await userDao.getUserById(id);
      // Assert

      expect(result, isNotNull);
    });
  });
}
