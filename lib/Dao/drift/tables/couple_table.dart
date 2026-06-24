import 'package:drift/drift.dart';
import 'user_profile_table.dart';

class Couples extends Table {
  @override
  String get actualTableName => 'couples';

  TextColumn get id => text()();

  @ReferenceName('user1Couples')
  TextColumn get user1Id => text().nullable().references(Profiles, #id)();

  @ReferenceName('user2Couples')
  TextColumn get user2Id => text().nullable().references(Profiles, #id)();

  TextColumn get inviteCode => text().nullable()();

  TextColumn get isUsable => text().withDefault(const Constant('WAITING'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
