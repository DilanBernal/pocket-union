import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

/// Database manager siguiendo patrón Singleton
/// Responsabilidad única: gestionar conexión y ciclo de vida de SQLite
class DbSqlite {
  static const _dbName = "pocket_union.db";
  static const _dbVersion = 1;

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

      debugPrint('📁 Inicializando DB en: $path');

      final db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );

      return db;
    } catch (e) {
      debugPrint('❌ Error inicializando DB: $e');
      rethrow;
    }
  }

  /// Configuración antes de abrir la DB
  Future _onConfigure(Database db) async {
    // Habilitar foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
    debugPrint('✅ Foreign keys habilitadas');
  }

  /// Crear schema inicial (v1)
  Future _onCreate(Database db, int version) async {
    debugPrint('🏗️  Creando schema v$version');

    await db.transaction((txn) async {
      // ========== TABLA: profile ==========
      await txn.execute('''
        CREATE TABLE profile (
          id TEXT PRIMARY KEY,
          full_name TEXT,
          avatar_url TEXT,
          updated_at TEXT,
          user_balance INTEGER NOT NULL DEFAULT 0,  -- En centavos
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
          -- Campos de sincronización
          sync_status TEXT NOT NULL DEFAULT 'pending' CHECK(sync_status IN ('pending', 'synced', 'conflict')),
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE
        )
      ''');

      // Índices para queries frecuentes
      await txn.execute('''
        CREATE INDEX idx_category_couple_id ON category(couple_id)
      ''');
      await txn.execute('''
        CREATE INDEX idx_category_sync_status ON category(sync_status)
      ''');

      // ========== TABLA: expense ==========
      await txn.execute('''
        CREATE TABLE expense (
          id TEXT PRIMARY KEY,
          couple_id TEXT NOT NULL,
          amount INTEGER NOT NULL,  -- En centavos
          description TEXT,
          category_id TEXT,
          transaction_date TEXT,
          is_fixed INTEGER NOT NULL DEFAULT 0,
          importance_level INTEGER NOT NULL DEFAULT 0 CHECK(importance_level >= 0 AND importance_level <= 5),
          is_planed INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          created_by TEXT NOT NULL,
          name TEXT NOT NULL CHECK(length(name) <= 50),
          -- Campos de sincronización
          sync_status TEXT NOT NULL DEFAULT 'pending',
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(category_id) REFERENCES category(id) ON DELETE SET NULL,
          FOREIGN KEY(created_by) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE INDEX idx_expense_couple_id ON expense(couple_id)
      ''');
      await txn.execute('''
        CREATE INDEX idx_expense_transaction_date ON expense(transaction_date)
      ''');
      await txn.execute('''
        CREATE INDEX idx_expense_category_id ON expense(category_id)
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

      // ========== TABLA: income ==========
      await txn.execute('''
        CREATE TABLE income (
          id TEXT PRIMARY KEY,
          couple_id TEXT,
          amount INTEGER NOT NULL,  -- En centavos
          description TEXT,
          category_id TEXT NOT NULL,
          transaction_date TEXT NOT NULL,
          is_recurring INTEGER NOT NULL DEFAULT 0,
          recurrence_interval TEXT,  -- JSON serializado
          is_received INTEGER NOT NULL DEFAULT 1,
          received_in TEXT,  -- JSON serializado
          created_at TEXT NOT NULL,
          name TEXT NOT NULL CHECK(length(name) < 100),
          user_recipient_id TEXT NOT NULL,
          -- Campos de sincronización
          sync_status TEXT NOT NULL DEFAULT 'pending',
          last_sync_at TEXT,
          local_updated_at TEXT NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(couple_id) REFERENCES couple(id) ON DELETE CASCADE,
          FOREIGN KEY(category_id) REFERENCES category(id) ON DELETE RESTRICT,
          FOREIGN KEY(user_recipient_id) REFERENCES profile(id) ON DELETE CASCADE
        )
      ''');

      // ========== TABLA: goal ==========
      await txn.execute('''
        CREATE TABLE goal (
          id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          couple_id TEXT NOT NULL,
          name TEXT NOT NULL,
          target_amount INTEGER NOT NULL,  -- En centavos
          current_amount INTEGER DEFAULT 0,  -- En centavos
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

      debugPrint('✅ Schema creado exitosamente');
    });
  }

  /// Manejar migraciones de versiones
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('📦 Migrando DB de v$oldVersion a v$newVersion');

    // Aquí irán las migraciones futuras
    // if (oldVersion < 2) { await _migrateToV2(db); }
    // if (oldVersion < 3) { await _migrateToV3(db); }
  }

  /// Cerrar conexión a la base de datos
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      debugPrint('🔒 Base de datos cerrada');
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

    debugPrint('🗑️  Base de datos eliminada');
  }
}
