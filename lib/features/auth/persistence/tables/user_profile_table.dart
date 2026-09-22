import 'package:drift/drift.dart';
import 'package:pocket_union/core/utils/app_database.dart';

import '../../domain/entities/user_entity.dart';

class UserProfileTable extends Table {
  @override
  String get tableName => 'profiles';

  TextColumn get id => text()();

  TextColumn get fullName => text().nullable()();

  TextColumn get avatarUrl => text().nullable()();

  RealColumn get userBalance => real().withDefault(const Constant(0.0))();

  BoolColumn get inCloud => boolean().withDefault(const Constant(false))();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  DateTimeColumn get lastSync => dateTime().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

UserProfileTableCompanion userProfileCompanionFromEntity(UserEntity user) {
  return UserProfileTableCompanion(
    id: Value(user.id),
    fullName: Value(user.fullName),
    avatarUrl: Value(user.avatarUrl),
    userBalance: Value(user.balance),
    inCloud: Value(user.inCloud),
    updatedAt: Value(user.lastSync),
    lastSync: Value(user.lastSync),
    syncStatus: Value('synced'),
    localUpdatedAt: Value(DateTime.now()),
    isDeleted: Value(false),
  );
}
