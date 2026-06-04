import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../features/auth/persistence/couple_table.dart';
import '../../features/auth/persistence/user_profile_table.dart';

part 'app_database.g.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
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
