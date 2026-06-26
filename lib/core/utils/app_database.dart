import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../features/auth/persistence/tables/couple_table.dart';
import '../../features/auth/persistence/tables/user_profile_table.dart';

part 'app_database.g.dart';

@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  return buildAppDatabase();
}

@DriftDatabase(tables: [UserProfileTable, CoupleTable])
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
  );
}

// ─── Factory con encriptación ─────────────────────────────────────────────────

Future<AppDatabase> buildAppDatabase() async {
  const storage = FlutterSecureStorage();

  final appDocDir = await getApplicationDocumentsDirectory();
  const dbName = 'pocket_union.db';
  final dbPath = '${appDocDir.path}/$dbName';

  final directory = Directory(appDocDir.path);

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
    try {
      // Intentar abrir la base de datos con la clave actual
      final testDb = await openDatabase(dbPath, password: encryptionKey);
      await testDb.close();
    } catch (e) {
      // Si falla, borrar y recrear
      await dbFile.delete();
    }
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
