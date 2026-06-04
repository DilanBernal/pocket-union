import 'package:drift/drift.dart';

import 'couple_table.dart';

// ─── Tablas ───────────────────────────────────────────────────────────────────

class Profiles extends Table {
  TextColumn get id => text()();

  TextColumn get fullName => text().nullable()();

  TextColumn get avatarUrl => text().nullable()();

  RealColumn get userBalance => real().withDefault(const Constant(0.0))();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  DateTimeColumn get lastSync => dateTime().nullable()();

  // Sync offline-first
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}


class Categories extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get coupleId => text().references(Couples, #id)();

  TextColumn get icon => text().nullable()();

  TextColumn get shortDescription => text().nullable()();

  TextColumn get color => text().nullable()();

  TextColumn get categoryHost => text()(); // enum: USER-DEFINED en Supabase
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text()();

  TextColumn get coupleId => text().references(Couples, #id)();

  RealColumn get amount => real()();

  TextColumn get description => text().nullable()();

  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  DateTimeColumn get transactionDate => dateTime().nullable()();

  BoolColumn get isFixed => boolean().withDefault(const Constant(false))();

  IntColumn get importanceLevel => integer().withDefault(const Constant(0))();

  BoolColumn get isPlaned => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get createdBy => text().references(Profiles, #id)();

  TextColumn get name => text()();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseShares extends Table {
  TextColumn get id => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get expenseId => text().references(Expenses, #id)();

  TextColumn get userId => text().references(Profiles, #id)();

  RealColumn get sharePercentage => real()();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Incomes extends Table {
  TextColumn get id => text()();

  TextColumn get coupleId => text().nullable().references(Couples, #id)();

  RealColumn get amount => real()();

  TextColumn get description => text().nullable()();

  TextColumn get categoryId => text().references(Categories, #id)();

  DateTimeColumn get transactionDate => dateTime()();

  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  TextColumn get recurrenceInterval => text().nullable()(); // JSON como String
  BoolColumn get isReceived => boolean().withDefault(const Constant(true))();

  TextColumn get receivedIn => text().nullable()(); // JSON como String
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get name => text()();

  TextColumn get userRecipientId => text().references(Profiles, #id)();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Goals extends Table {
  TextColumn get id => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get coupleId => text().references(Couples, #id)();

  TextColumn get name => text()();

  RealColumn get targetAmount => real()();

  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();

  DateTimeColumn get deadline => dateTime().nullable()();

  TextColumn get description => text().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class GoalContributions extends Table {
  TextColumn get id => text()();

  TextColumn get goalId => text().references(Goals, #id)();

  TextColumn get userId => text().references(Profiles, #id)();

  RealColumn get amount => real().withDefault(const Constant(50.0))();

  DateTimeColumn get contributionDate => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── AppDatabase ──────────────────────────────────────────────────────────────
