import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/reference/persistence/tables/category_table.dart';
import 'package:pocket_union/features/transaction/persistence/tables/expense_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../features/auth/persistence/tables/couple_table.dart';
import '../../features/auth/persistence/tables/user_profile_table.dart';

part 'app_database.g.dart';

@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  return buildAppDatabase();
}

@DriftDatabase(
  tables: [
    UserProfileTable,
    CoupleTable,
    ExpenseTable,
    ExpenseCategories,
    CategoryTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 4) {
        await m.addColumn(userProfileTable, userProfileTable.updatedAt);
        await m.addColumn(userProfileTable, userProfileTable.syncStatus);
        await m.addColumn(userProfileTable, userProfileTable.localUpdatedAt);
        await m.addColumn(userProfileTable, userProfileTable.isDeleted);
      }
    },
    beforeOpen: (details) async {
      await customSelect('PRAGMA journal_mode=WAL').get();
      await customStatement('PRAGMA synchronous=NORMAL');
      await customStatement('PRAGMA foreign_keys=ON');
    },
  );
}

// ─── Factory con encriptación ─────────────────────────────────────────────────

Future<AppDatabase> buildAppDatabase() async {
  const storage = FlutterSecureStorage();

  final dbFolder = await getDatabasesPath();
  const dbName = 'pocket_union.db';
  final dbPath = p.join(dbFolder, dbName);

  final directory = Directory(dbFolder);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  // Obtener o generar la clave de encriptación
  String? encryptionKey = await storage.read(key: 'db_encryption_key');
  if (encryptionKey == null) {
    // Genera una clave aleatoria segura la primera vez
    encryptionKey = _generateSecureKey();
    await storage.write(key: 'db_encryption_key', value: encryptionKey);
  }
  final dbFile = File(dbPath);

  if (await dbFile.exists()) {
    final isHealthy = await _isDatabaseHealthy(dbPath, encryptionKey);
    if (!isHealthy) {
      await _quarantineCorruptedDatabase(dbPath);
    }
  }

  final executor = SqfliteQueryExecutor(
    singleInstance: true,
    creator: (path) => openDatabase(path.path, password: encryptionKey),
    path: dbPath,
  );

  return AppDatabase(executor);
}

/// Abre la DB y corre un integrity_check real. Un `openDatabase` exitoso
/// no garantiza que el contenido esté sano (puede abrir y fallar recién
/// al leer una página corrupta), así que validamos con PRAGMA.
Future<bool> _isDatabaseHealthy(String dbPath, String encryptionKey) async {
  Database? testDb;
  try {
    testDb = await openDatabase(dbPath, password: encryptionKey);
    final result = await testDb.rawQuery('PRAGMA integrity_check');
    final status = result.isNotEmpty ? result.first.values.first : null;
    return status == 'ok';
  } catch (_) {
    return false;
  } finally {
    await testDb?.close();
  }
}

/// Mueve el archivo corrupto a un backup en vez de borrarlo directo,
/// y limpia los sidecar files (-wal, -shm, -journal) que si quedan
/// huérfanos son la causa más común de un open_failed en el siguiente
/// arranque, incluso con el .db principal sano.
Future<void> _quarantineCorruptedDatabase(String dbPath) async {
  final dbFile = File(dbPath);
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  try {
    if (await dbFile.exists()) {
      await dbFile.copy('$dbPath.corrupt_$timestamp');
      await dbFile.delete();
    }
  } catch (_) {
    // Si ni copiar/borrar funciona, seguimos igual: mejor perder el
    // archivo que dejar la app sin poder arrancar.
  }

  for (final suffix in ['-wal', '-shm', '-journal']) {
    final sidecar = File('$dbPath$suffix');
    if (await sidecar.exists()) {
      try {
        await sidecar.delete();
      } catch (_) {}
    }
  }
}

String _generateSecureKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
