import 'package:drift/drift.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/features/auth/persistence/tables/couple_table.dart';
import 'package:pocket_union/features/auth/persistence/tables/user_profile_table.dart';
import 'package:pocket_union/features/reference/persistence/tables/category_table.dart';

class IncomeTable extends Table {
  @override
  String? get tableName => 'expense';

  TextColumn get id => text()();

  @ReferenceName('couple')
  TextColumn get coupleId => text().nullable().references(CoupleTable, #id)();

  TextColumn get name => text()();

  @ReferenceName('creator')
  TextColumn get createdBy =>
      text().nullable().references(UserProfileTable, #id)();

  @ReferenceName('recipient')
  TextColumn get userRecipientId =>
      text().nullable().references(UserProfileTable, #id)();
  DateTimeColumn get transactionDate =>
      dateTime().withDefault(currentDateAndTime)();

  @ReferenceName('category')
  TextColumn get categoryId =>
      text().nullable().references(CategoryTable, #id)();

  TextColumn get description => text().nullable()();

  RealColumn get amount => real()();

  BoolColumn get isReceived => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
    Constant(SyncStatus.pendingCreate.index),
  )();

  DateTimeColumn get localUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column>? get primaryKey => {id};
}

class IncomeCategories extends Table {
  @ReferenceName('income')
  @ReferenceName('category')
  TextColumn get incomeId => text().references(IncomeTable, #id)();
  TextColumn get categoryId => text().references(CategoryTable, #id)();

  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(
    Constant(SyncStatus.pendingCreate.index),
  )();

  DateTimeColumn get localUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {incomeId, categoryId};
}
