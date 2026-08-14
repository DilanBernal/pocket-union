import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:pocket_union/core/utils/app_database.dart';

AppDatabase getMockDatabase() {
  return AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}
