import 'package:drift/drift.dart';

import 'couple_table.dart';
import 'user_profile_table.dart';

class RecurrentExpenses extends Table {
  @override
  String get actualTableName => 'recurrent_expenses';

  TextColumn get id => text()();

  TextColumn get coupleId => text().references(Couples, #id)();

  TextColumn get createdBy => text().nullable().references(Profiles, #id)();

  TextColumn get name => text()();

  RealColumn get amount => real()();

  TextColumn get recurrentInfo => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
