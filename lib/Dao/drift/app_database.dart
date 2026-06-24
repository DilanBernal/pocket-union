import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'tables/couple_table.dart';
import 'tables/recurrent_expense_table.dart';
import 'tables/recurrent_income_table.dart';
import 'tables/user_profile_table.dart';

part 'app_database.g.dart';

@riverpod
Future<AppDatabase> appDatabase(Ref ref) async {
  return buildAppDatabase();
}

@DriftDatabase(
  tables: [
    Profiles,
    Couples,
    Categories,
    Expenses,
    ExpenseShares,
    Incomes,
    Goals,
    GoalContributions,
    RecurrentExpenses,
    RecurrentIncomes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 4) {
        await m.addColumn(profiles, profiles.updatedAt);
        await m.addColumn(profiles, profiles.syncStatus);
        await m.addColumn(profiles, profiles.localUpdatedAt);
        await m.addColumn(profiles, profiles.isDeleted);
      }
      if (from < 5) {
        await m.addColumn(couples, couples.inviteCode);
        await _ensureRecurrentTable(m);
      }
      if (from < 6) {
        await _migrateToV6(m);
      }
    },
  );
}

Future<void> _ensureRecurrentTable(Migrator m) async {
  await m.database.customStatement(
    'CREATE TABLE IF NOT EXISTS recurrent_expenses ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'couple_id TEXT NOT NULL REFERENCES couples(id), '
    'created_by TEXT REFERENCES profiles(id), '
    'name TEXT NOT NULL DEFAULT \'\', '
    'amount REAL NOT NULL, '
    'recurrent_info TEXT, '
    'created_at TEXT NOT NULL, '
    'sync_status TEXT NOT NULL DEFAULT \'synced\', '
    'local_updated_at TEXT, '
    'is_deleted INTEGER NOT NULL DEFAULT 0'
    ')',
  );
  await _addColumnIfNotExists(m, 'recurrent_expenses', 'local_updated_at',
      'TEXT');
  await _addColumnIfNotExists(
      m, 'recurrent_expenses', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');

  await m.database.customStatement(
    'CREATE TABLE IF NOT EXISTS recurrent_incomes ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'couple_id TEXT NOT NULL REFERENCES couples(id), '
    'user_recipient_id TEXT REFERENCES profiles(id), '
    'name TEXT NOT NULL DEFAULT \'\', '
    'amount REAL NOT NULL, '
    'recurrent_info TEXT, '
    'created_at TEXT NOT NULL, '
    'sync_status TEXT NOT NULL DEFAULT \'synced\', '
    'local_updated_at TEXT, '
    'is_deleted INTEGER NOT NULL DEFAULT 0'
    ')',
  );
  await _addColumnIfNotExists(
      m, 'recurrent_incomes', 'local_updated_at', 'TEXT');
  await _addColumnIfNotExists(
      m, 'recurrent_incomes', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
}

Future<void> _addColumnIfNotExists(
    Migrator m, String table, String column, String sqlType) async {
  try {
    await m.database.customStatement(
        'ALTER TABLE $table ADD COLUMN $column $sqlType');
  } catch (_) {
  }
}

Future<void> _migrateToV6(Migrator m) async {
  final isOldFormat = await _hasOldInfoTables(m);

  if (isOldFormat) {
    await m.database.customStatement('UPDATE expenses SET amount = amount / 100.0');
    await m.database.customStatement('UPDATE incomes SET amount = amount / 100.0');
    await m.database.customStatement('UPDATE recurrent_expenses SET amount = amount / 100.0');
    await m.database.customStatement('UPDATE recurrent_incomes SET amount = amount / 100.0');
  }

  await _addColumnIfNotExists(m, 'expenses', 'category_id', 'TEXT');
  await _addColumnIfNotExists(m, 'expenses', 'is_fixed', 'INTEGER NOT NULL DEFAULT 0');
  await _addColumnIfNotExists(m, 'expenses', 'importance_level', 'INTEGER NOT NULL DEFAULT 0');
  await _addColumnIfNotExists(m, 'expenses', 'is_planed', 'INTEGER NOT NULL DEFAULT 0');

  await _addColumnIfNotExists(m, 'incomes', 'category_id', 'TEXT');
  await _addColumnIfNotExists(m, 'incomes', 'is_recurring', 'INTEGER NOT NULL DEFAULT 0');
  await _addColumnIfNotExists(m, 'incomes', 'recurrence_interval', 'TEXT');
  await _addColumnIfNotExists(m, 'incomes', 'received_in', 'TEXT');

  await _addColumnIfNotExists(m, 'expense_shares', 'local_updated_at', 'TEXT');
  await _addColumnIfNotExists(m, 'expense_shares', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
  await _addColumnIfNotExists(m, 'goals', 'local_updated_at', 'TEXT');
  await _addColumnIfNotExists(m, 'goals', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
  await _addColumnIfNotExists(m, 'goal_contributions', 'local_updated_at', 'TEXT');
  await _addColumnIfNotExists(m, 'goal_contributions', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');

  if (isOldFormat) {
    try {
      await m.database.customStatement('''
        UPDATE expenses SET
          is_fixed = COALESCE((SELECT is_fixed FROM expense_info WHERE expense_info.id = expenses.id), 0),
          is_planed = COALESCE((SELECT is_planed FROM expense_info WHERE expense_info.id = expenses.id), 0),
          importance_level = COALESCE((SELECT importance_level FROM expense_info WHERE expense_info.id = expenses.id), 0)
      ''');
    } catch (_) {}

    try {
      await m.database.customStatement('''
        UPDATE incomes SET
          is_recurring = COALESCE((SELECT is_recurring FROM income_info WHERE income_info.income_id = incomes.id), 0),
          received_in = (SELECT received_in FROM income_info WHERE income_info.income_id = incomes.id)
      ''');
    } catch (_) {}

    try {
      await m.database.customStatement('''
        UPDATE expenses SET category_id = (
          SELECT category_id FROM expense_category
          WHERE expense_category.expense_id = expenses.id
          LIMIT 1
        )
      ''');
    } catch (_) {}

    try {
      await m.database.customStatement('''
        UPDATE incomes SET category_id = (
          SELECT category_id FROM income_category
          WHERE income_category.income_id = incomes.id
          LIMIT 1
        )
      ''');
    } catch (_) {}
  }
}

Future<bool> _hasOldInfoTables(Migrator m) async {
  try {
    final rows = await m.database
        .customSelect(
          "SELECT count(*) AS cnt FROM sqlite_master WHERE type='table' AND name='expense_info'",
        )
        .get();
    if (rows.isEmpty) return false;
    return (rows.first.data['cnt'] as int) > 0;
  } catch (_) {
    return false;
  }
}

// ─── Factory con encriptación ─────────────────────────────────────────────────

Future<AppDatabase> buildAppDatabase() async {
  const storage = FlutterSecureStorage();
  const dbName = 'pocket_union.db';

  // Obtener o generar la clave de encriptación
  String? encryptionKey = await storage.read(key: 'db_encryption_key');
  if (encryptionKey == null) {
    // Genera una clave aleatoria segura la primera vez
    encryptionKey = _generateSecureKey();
    await storage.write(key: 'db_encryption_key', value: encryptionKey);
  }

  final executor = SqfliteQueryExecutor(
    singleInstance: true,
    creator: (path) => openDatabase(path.path, password: encryptionKey),
    path: dbName,
  );

  return AppDatabase(executor);
}

String _generateSecureKey() {
  // 32 bytes aleatorios como hex
  final random = List.generate(
    32,
    (_) => (DateTime.now().microsecondsSinceEpoch & 0xFF),
  );
  return random.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
