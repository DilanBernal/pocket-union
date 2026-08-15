import 'package:drift/drift.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/features/auth/persistence/tables/couple_table.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';

class CategoryTable extends Table {
  @override
  String? get tableName => 'category';

  TextColumn get id => text()();

  @ReferenceName('couple')
  TextColumn get coupleId => text().references(CoupleTable, #id)();

  TextColumn get name => text()();

  TextColumn get icon => text().nullable()();

  TextColumn get shortDescription => text().nullable()();

  TextColumn get color => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get categoryHost => intEnum<CategoryHost>()();

  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
    Constant(SyncStatus.pendingCreate.index),
  )();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  DateTimeColumn get localDeletedAt => dateTime().nullable()();

  @override
  Set<Column>? get primaryKey => {id};
}

CategoryTableCompanion categoryTableCompanionFromEntity(
  CategoryEntity category,
) {
  return CategoryTableCompanion(
    id: Value(category.id),
    coupleId: Value(category.coupleId),
    name: Value(category.name),
    icon: Value(category.icon),
    shortDescription: Value(category.shortDescription),
    color: Value(category.color),
    createdAt: Value(category.createdAt),
    categoryHost: Value(category.categoryHost),
    syncStatus: Value(category.syncStatus),
    localUpdatedAt: Value(category.localUpdatedAt),
    lastSyncedAt: Value(category.lastSyncedAt),
    localDeletedAt: Value(category.localDeletedAt),
  );
}
