import 'dart:developer' as dev;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database manager siguiendo patrón Singleton
/// Responsabilidad única: gestionar conexión y ciclo de vida de SQLite
class DbSqlite {
  static const _dbName = "pocket_union.db";
  static const _dbVersion = 2;

  static final DbSqlite instance = DbSqlite._internal();
  DbSqlite._internal();

  Database? _db;

  /// Getter lazy para la base de datos
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Inicialización de la base de datos
  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      dev.log('Inicializando DB en: $path', name: 'DbSqlite');

      final db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );

      return db;
    } catch (e) {
      dev.log('Error inicializando DB: $e', name: 'DbSqlite', level: 1000);
      rethrow;
    }
  }

  /// Configuración antes de abrir la DB
  Future _onConfigure(Database db) async {
    // Habilitar foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
    dev.log('Foreign keys habilitadas', name: 'DbSqlite');
  }

  /// Crear schema v2
  Future _onCreate(Database db, int version) async {
    dev.log('Creando schema v$version', name: 'DbSqlite');

    await db.transaction((txn) async {
      // ========== TABLA: profile ==========
      await txn.execute('''
        CREATE TABLE profile (
          id TEXT PRIMARY KEY,
          full_name TEXT,
          avatar_url TEXT,
          user_balance INTEGER NOT NULL DEFAULT 0,
          in_cloud INTEGER NOT NULL DEFAULT 0,
          last_sync TEXT
        )
      ''');

      // ========== TABLA: couple ==========
      await txn.execute('''
        CREATE TABLE couple (
          id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          user1_id TEXT,
          user2_id TEXT,
          invite_code TEXT UNIQUE,
          is_usable TEXT NOT NULL DEFAULT 'WAITING',
          FOREIGN KEY(user1_id) REFERENCES profile(id) ON DELETE SET NULL,
          FOREIGN KEY(user2_id) REFERENCES profile(id) ON DELETE SET NULL
        )
      ''');

      // ========== TABLA: category ==========
      await txn.execute('''
        CREATE TABLE category (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          couple_id TEXT NOT NULL,
          icon TEXT,
          short_description TEXT,
          color TEXT,
          created_at TEXT NOT NULL,
          category_host TEXT NOT NULL CHECK(category_host IN ('INCOME', 'EXPENSE')),
          sync_status TEXT NOT NULL DEFAULT 'pending' CHECK(sync_status IN ('pending', 'synced', 'conflict')),
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute(
        'CREATE INDEX idx_category_couple_id ON category(couple_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_category_sync_status ON category(sync_status)',
      );

      // ========== TABLA: income ==========
      await txn.execute('''
        CREATE TABLE income (
          id TEXT PRIMARY KEY,
          couple_id TEXT,
          amount INTEGER NOT NULL,
          description TEXT,
          transaction_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_received INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          name TEXT NOT NULL CHECK(length(name) < 100),
          user_recipient_id TEXT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending',
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(user_recipient_id) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: income_info ==========
      await txn.execute('''
        CREATE TABLE income_info (
          income_id TEXT PRIMARY KEY,
          is_recurring INTEGER NOT NULL DEFAULT 0,
          is_received INTEGER NOT NULL DEFAULT 1,
          received_in TEXT,
          FOREIGN KEY(income_id) REFERENCES income(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: income_category (N:N) ==========
      await txn.execute('''
        CREATE TABLE income_category (
          income_id TEXT NOT NULL,
          category_id TEXT NOT NULL,
          PRIMARY KEY(income_id, category_id),
          FOREIGN KEY(income_id) REFERENCES income(id) ON DELETE CASCADE,
          FOREIGN KEY(category_id) REFERENCES category(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: expense ==========
      await txn.execute('''
        CREATE TABLE expense (
          id TEXT PRIMARY KEY,
          couple_id TEXT NOT NULL,
          amount INTEGER NOT NULL,
          description TEXT,
          transaction_date TEXT,
          created_at TEXT NOT NULL,
          created_by TEXT NOT NULL,
          name TEXT NOT NULL CHECK(length(name) <= 50),
          sync_status TEXT NOT NULL DEFAULT 'pending',
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          is_paid INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(created_by) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute(
        'CREATE INDEX idx_expense_couple_id ON expense(couple_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_expense_transaction_date ON expense(transaction_date)',
      );

      // ========== TABLA: expense_info ==========
      await txn.execute('''
        CREATE TABLE expense_info (
          id TEXT PRIMARY KEY,
          is_fixed INTEGER NOT NULL DEFAULT 0,
          is_planed INTEGER NOT NULL DEFAULT 0,
          importance_level INTEGER NOT NULL DEFAULT 0 CHECK(importance_level >= 0 AND importance_level <= 5),
          FOREIGN KEY(id) REFERENCES expense(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: expense_category (N:N) ==========
      await txn.execute('''
        CREATE TABLE expense_category (
          expense_id TEXT NOT NULL,
          category_id TEXT NOT NULL,
          PRIMARY KEY(expense_id, category_id),
          FOREIGN KEY(expense_id) REFERENCES expense(id) ON DELETE CASCADE,
          FOREIGN KEY(category_id) REFERENCES category(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: expense_share ==========
      await txn.execute('''
        CREATE TABLE expense_share (
          id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          expense_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          share_percentage REAL NOT NULL CHECK(share_percentage >= 0 AND share_percentage <= 100),
          sync_status TEXT NOT NULL DEFAULT 'pending',
          FOREIGN KEY(expense_id) REFERENCES expense(id) ON DELETE CASCADE,
          FOREIGN KEY(user_id) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: recurrent_income ==========
      await txn.execute('''
        CREATE TABLE recurrent_income (
          id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          name TEXT NOT NULL DEFAULT '',
          user_recipient_id TEXT,
          couple_id TEXT NOT NULL,
          amount INTEGER NOT NULL,
          recurrent_info TEXT,
          sync_status TEXT NOT NULL DEFAULT 'pending',
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(user_recipient_id) REFERENCES profile(id) ON DELETE SET NULL
        )
      ''');

      // ========== TABLA: goal ==========
      await txn.execute('''
        CREATE TABLE goal (
          id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          couple_id TEXT NOT NULL,
          name TEXT NOT NULL,
          target_amount INTEGER NOT NULL,
          current_amount INTEGER DEFAULT 0,
          deadline TEXT,
          description TEXT,
          sync_status TEXT NOT NULL DEFAULT 'pending',
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: goal_contribution ==========
      await txn.execute('''
        CREATE TABLE goal_contribution (
          id TEXT PRIMARY KEY,
          goal_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          amount INTEGER NOT NULL DEFAULT 0,
          contribution_date TEXT,
          created_at TEXT NOT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending',
          FOREIGN KEY(goal_id) REFERENCES goal(id) ON DELETE CASCADE,
          FOREIGN KEY(user_id) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      dev.log('Schema v2 creado exitosamente', name: 'DbSqlite');
    });
  }

  /// Manejar migraciones de versiones
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    dev.log('Migrando DB de v$oldVersion a v$newVersion', name: 'DbSqlite');

    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
  }

  /// Migración v1 → v2: Split income/expense en tablas info + category (N:N)
  Future _migrateToV2(Database db) async {
    await db.transaction((txn) async {
      // --- INCOME: crear tablas nuevas y migrar datos ---

      await txn.execute('''
        CREATE TABLE income_info (
          income_id TEXT PRIMARY KEY,
          is_recurring INTEGER NOT NULL DEFAULT 0,
          is_received INTEGER NOT NULL DEFAULT 1,
          received_in TEXT,
          FOREIGN KEY(income_id) REFERENCES income(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE TABLE income_category (
          income_id TEXT NOT NULL,
          category_id TEXT NOT NULL,
          PRIMARY KEY(income_id, category_id),
          FOREIGN KEY(income_id) REFERENCES income(id) ON DELETE CASCADE,
          FOREIGN KEY(category_id) REFERENCES category(id) ON DELETE CASCADE
        )
      ''');

      // Migrar datos existentes a income_info
      await txn.execute('''
        INSERT INTO income_info (income_id, is_recurring, is_received, received_in)
        SELECT id, is_recurring, is_received, received_in FROM income
      ''');

      // Migrar category_id existentes a income_category
      await txn.execute('''
        INSERT INTO income_category (income_id, category_id)
        SELECT id, category_id FROM income WHERE category_id IS NOT NULL
      ''');

      // Recrear tabla income sin columnas movidas
      await txn.execute('''
        CREATE TABLE income_new (
          id TEXT PRIMARY KEY,
          couple_id TEXT,
          amount INTEGER NOT NULL,
          description TEXT,
          transaction_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_received INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          name TEXT NOT NULL CHECK(length(name) < 100),
          user_recipient_id TEXT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending',
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(user_recipient_id) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('''
        INSERT INTO income_new (id, couple_id, amount, description, transaction_date,
          is_received, created_at, name, user_recipient_id, sync_status,
          last_sync_at, local_updated_at, is_deleted)
        SELECT id, couple_id, amount, description, transaction_date,
          is_received, created_at, name, user_recipient_id, sync_status,
          last_sync_at, local_updated_at, is_deleted
        FROM income
      ''');

      await txn.execute('DROP TABLE income');
      await txn.execute('ALTER TABLE income_new RENAME TO income');

      // --- EXPENSE: crear tablas nuevas y migrar datos ---

      await txn.execute('''
        CREATE TABLE expense_info (
          id TEXT PRIMARY KEY,
          is_fixed INTEGER NOT NULL DEFAULT 0,
          is_planed INTEGER NOT NULL DEFAULT 0,
          importance_level INTEGER NOT NULL DEFAULT 0 CHECK(importance_level >= 0 AND importance_level <= 5),
          FOREIGN KEY(id) REFERENCES expense(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE TABLE expense_category (
          expense_id TEXT NOT NULL,
          category_id TEXT NOT NULL,
          PRIMARY KEY(expense_id, category_id),
          FOREIGN KEY(expense_id) REFERENCES expense(id) ON DELETE CASCADE,
          FOREIGN KEY(category_id) REFERENCES category(id) ON DELETE CASCADE
        )
      ''');

      // Migrar datos a expense_info
      await txn.execute('''
        INSERT INTO expense_info (id, is_fixed, is_planed, importance_level)
        SELECT id, is_fixed, is_planed, importance_level FROM expense
      ''');

      // Migrar category_id a expense_category
      await txn.execute('''
        INSERT INTO expense_category (expense_id, category_id)
        SELECT id, category_id FROM expense WHERE category_id IS NOT NULL
      ''');

      // Recrear expense sin columnas movidas
      await txn.execute('''
        CREATE TABLE expense_new (
          id TEXT PRIMARY KEY,
          couple_id TEXT NOT NULL,
          amount INTEGER NOT NULL,
          description TEXT,
          transaction_date TEXT,
          created_at TEXT NOT NULL,
          created_by TEXT NOT NULL,
          name TEXT NOT NULL CHECK(length(name) <= 50),
          sync_status TEXT NOT NULL DEFAULT 'pending',
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(created_by) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('''
        INSERT INTO expense_new (id, couple_id, amount, description, transaction_date,
          created_at, created_by, name, sync_status, last_sync_at,
          local_updated_at, is_deleted)
        SELECT id, couple_id, amount, description, transaction_date,
          created_at, created_by, name, sync_status, last_sync_at,
          local_updated_at, is_deleted
        FROM expense
      ''');

      await txn.execute('DROP TABLE expense');
      await txn.execute('ALTER TABLE expense_new RENAME TO expense');

      // Recrear índices de expense
      await txn.execute(
        'CREATE INDEX idx_expense_couple_id ON expense(couple_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_expense_transaction_date ON expense(transaction_date)',
      );

      // --- RECURRENT_INCOME ---
      await txn.execute('''
        CREATE TABLE recurrent_income (
          id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          name TEXT NOT NULL DEFAULT '',
          user_recipient_id TEXT,
          couple_id TEXT NOT NULL,
          amount INTEGER NOT NULL,
          recurrent_info TEXT,
          sync_status TEXT NOT NULL DEFAULT 'pending',
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(user_recipient_id) REFERENCES profile(id) ON DELETE SET NULL
        )
      ''');

      dev.log('Migración a v2 completada', name: 'DbSqlite');
    });
  }

  /// Cerrar conexión a la base de datos
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      dev.log('Base de datos cerrada', name: 'DbSqlite');
    }
  }

  /// Resetear base de datos (solo para desarrollo/testing)
  Future<void> reset() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);

    dev.log('Base de datos eliminada', name: 'DbSqlite');
  }
}
