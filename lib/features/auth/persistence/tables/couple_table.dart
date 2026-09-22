import 'package:drift/drift.dart';
import '../../../../core/utils/app_database.dart';
import '../../domain/entities/couple_entity.dart';
import 'user_profile_table.dart';

class CoupleTable extends Table {
  @override
  String get tableName => 'couples';

  TextColumn get id => text()();

  @ReferenceName('user1Couple')
  TextColumn get user1Id =>
      text().nullable().references(UserProfileTable, #id)();

  @ReferenceName('user2Couple')
  TextColumn get user2Id =>
      text().nullable().references(UserProfileTable, #id)();

  TextColumn get isUsable => text().withDefault(const Constant('WAITING'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

CoupleTableCompanion coupleTableCompanionFromEntity(CoupleEntity couple) {
  return CoupleTableCompanion(
    id: Value(couple.id),
    user1Id: Value(couple.user1Id),
    user2Id: Value(couple.user2Id),
    isUsable: Value(couple.isUsable.value),
    // syncStatus: Value(Couple),
  );
}
