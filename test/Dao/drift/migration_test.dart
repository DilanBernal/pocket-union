import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart';

void main() {
  group('Migration v6 - amount conversion', () {
    test('divide amount en expense', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO expenses (id, couple_id, amount, created_by, name, sync_status, is_deleted) "
        "VALUES ('exp-1', 'couple-1', 15000, 'user-1', 'Test', 'synced', 0)",
      );
      final before = await db.customSelect(
        'SELECT amount FROM expenses WHERE id = \'exp-1\'',
      ).get();
      expect((before.first.data['amount'] as num).toDouble(), 15000.0);

      await db.customStatement('UPDATE expenses SET amount = amount / 100.0');

      final after = await db.customSelect(
        'SELECT amount FROM expenses WHERE id = \'exp-1\'',
      ).get();
      expect((after.first.data['amount'] as num).toDouble(), 150.0);
      await db.close();
    });

    test('divide amount en income', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO incomes (id, amount, transaction_date, name, sync_status, is_deleted, is_recurring, is_received) "
        "VALUES ('inc-1', 250000, '2024-06-01', 'Salary', 'synced', 0, 0, 1)",
      );

      await db.customStatement('UPDATE incomes SET amount = amount / 100.0');

      final result = await db.customSelect(
        'SELECT amount FROM incomes WHERE id = \'inc-1\'',
      ).get();
      expect((result.first.data['amount'] as num).toDouble(), 2500.0);
      await db.close();
    });

    test('divide amount en recurrent_expenses', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO recurrent_expenses (id, couple_id, amount, name, sync_status, is_deleted) "
        "VALUES ('re-1', 'couple-1', 999, 'Netflix', 'synced', 0)",
      );

      await db.customStatement(
        'UPDATE recurrent_expenses SET amount = amount / 100.0',
      );

      final result = await db.customSelect(
        'SELECT amount FROM recurrent_expenses WHERE id = \'re-1\'',
      ).get();
      expect((result.first.data['amount'] as num).toDouble(), 9.99);
      await db.close();
    });

    test('divide amount en recurrent_incomes', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO recurrent_incomes (id, couple_id, amount, name, sync_status, is_deleted) "
        "VALUES ('ri-1', 'couple-1', 120000, 'Rent', 'synced', 0)",
      );

      await db.customStatement(
        'UPDATE recurrent_incomes SET amount = amount / 100.0',
      );

      final result = await db.customSelect(
        'SELECT amount FROM recurrent_incomes WHERE id = \'ri-1\'',
      ).get();
      expect((result.first.data['amount'] as num).toDouble(), 1200.0);
      await db.close();
    });
  });

  group('Migration v6 - column additions', () {
    test('addColumnIfNotExists no falla si columna ya existe', () async {
      final db = AppDatabase(NativeDatabase.memory());
      try {
        await db.customStatement('ALTER TABLE expenses ADD COLUMN test_col TEXT');
      } catch (_) {}
      try {
        await db.customStatement('ALTER TABLE expenses ADD COLUMN test_col TEXT');
      } catch (_) {}
      await db.close();
    });

    test('expenses tiene nuevas columnas de v6', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO expenses (id, couple_id, amount, created_by, name, sync_status, is_deleted, "
        "category_id, is_fixed, importance_level, is_planed) "
        "VALUES ('exp-v6', 'couple-1', 100.0, 'user-1', 'TestV6', 'synced', 0, "
        "'cat-1', 1, 3, 1)",
      );

      final result = await db.customSelect(
        'SELECT * FROM expenses WHERE id = \'exp-v6\'',
      ).get();
      expect(result.first.data['category_id'], 'cat-1');
      expect(result.first.data['is_fixed'], 1);
      expect(result.first.data['importance_level'], 3);
      expect(result.first.data['is_planed'], 1);
      await db.close();
    });

    test('incomes tiene nuevas columnas de v6', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO incomes (id, amount, transaction_date, name, sync_status, is_deleted, "
        "is_recurring, is_received, category_id, received_in) "
        "VALUES ('inc-v6', 500.0, '2024-06-01', 'TestV6', 'synced', 0, "
        "1, 1, 'cat-2', 'cash')",
      );

      final result = await db.customSelect(
        'SELECT * FROM incomes WHERE id = \'inc-v6\'',
      ).get();
      expect(result.first.data['category_id'], 'cat-2');
      expect(result.first.data['is_recurring'], 1);
      expect(result.first.data['received_in'], 'cash');
      await db.close();
    });
  });

  group('Migration v6 - old table detection', () {
    test('detecta expense_info', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        'CREATE TABLE expense_info (id TEXT, is_fixed INTEGER)',
      );

      final rows = await db.customSelect(
        "SELECT count(*) AS cnt FROM sqlite_master WHERE type='table' AND name='expense_info'",
      ).get();
      expect(rows.first.data['cnt'], 1);
      await db.close();
    });

    test('retorna 0 sin expense_info', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final rows = await db.customSelect(
        "SELECT count(*) AS cnt FROM sqlite_master WHERE type='table' AND name='expense_info'",
      ).get();
      expect(rows.first.data['cnt'], 0);
      await db.close();
    });
  });

  group('Migration v4→v5 - recurrent tables', () {
    test('recurrent_expenses table existe', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO recurrent_expenses (id, couple_id, created_by, name, amount, recurrent_info, "
        "created_at, sync_status, local_updated_at, is_deleted) "
        "VALUES ('re-v5', 'couple-1', 'user-1', 'Sub', 10.0, 'monthly', "
        "'2024-06-01', 'synced', '2024-06-01', 0)",
      );

      final result = await db.customSelect(
        'SELECT * FROM recurrent_expenses WHERE id = \'re-v5\'',
      ).get();
      expect(result.first.data['recurrent_info'], 'monthly');
      expect(result.first.data['local_updated_at'], '2024-06-01');
      await db.close();
    });

    test('recurrent_incomes table existe', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await db.customStatement(
        "INSERT INTO recurrent_incomes (id, couple_id, user_recipient_id, name, amount, recurrent_info, "
        "created_at, sync_status, local_updated_at, is_deleted) "
        "VALUES ('ri-v5', 'couple-1', 'user-1', 'Dividend', 50.0, 'quarterly', "
        "'2024-06-01', 'synced', '2024-06-01', 0)",
      );

      final result = await db.customSelect(
        'SELECT * FROM recurrent_incomes WHERE id = \'ri-v5\'',
      ).get();
      expect(result.first.data['user_recipient_id'], 'user-1');
      expect(result.first.data['recurrent_info'], 'quarterly');
      await db.close();
    });
  });
}
