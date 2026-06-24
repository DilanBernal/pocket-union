import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

part 'app_database.g.dart';

@riverpod
Future<AppDatabase> appDatabase(Ref ref) async {
  return buildAppDatabase();
}

@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 4) {
        // await m.addColumn(profiles, profiles.updatedAt);
        // await m.addColumn(profiles, profiles.syncStatus);
        // await m.addColumn(profiles, profiles.localUpdatedAt);
        // await m.addColumn(profiles, profiles.isDeleted);
      }
    },
  );
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
