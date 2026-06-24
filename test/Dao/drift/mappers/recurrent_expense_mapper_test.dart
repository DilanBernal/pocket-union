import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/recurrent_expense_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/recurrent_expense.dart';

void main() {
  final mapper = RecurrentExpenseMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('RecurrentExpenseMapper.toDomain', () {
    test('convierte Drift RecurrentExpense a RecurrentExpense de dominio', () {
      final driftExpense = drift.RecurrentExpense(
        id: 're-1',
        coupleId: 'couple-1',
        createdBy: 'user-1',
        name: 'Netflix',
        amount: 15.99,
        recurrentInfo: 'monthly',
        createdAt: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftExpense);

      expect(domain.id, 're-1');
      expect(domain.coupleId, 'couple-1');
      expect(domain.createdBy, 'user-1');
      expect(domain.name, 'Netflix');
      expect(domain.amount, 15.99);
      expect(domain.recurrentInfo, 'monthly');
      expect(domain.createdAt, now);
      expect(domain.syncStatus, SyncStatus.synced);
    });

    test('createdBy null mapea a string vacío', () {
      final driftExpense = drift.RecurrentExpense(
        id: 're-2',
        coupleId: 'couple-1',
        name: 'Spotify',
        amount: 9.99,
        createdAt: now,
        syncStatus: 'pending',
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftExpense);

      expect(domain.createdBy, '');
    });
  });

  group('RecurrentExpenseMapper.toCompanion', () {
    test('convierte RecurrentExpense de dominio a RecurrentExpensesCompanion', () {
      final domain = RecurrentExpense(
        id: 're-1',
        coupleId: 'couple-1',
        createdBy: 'user-1',
        name: 'Netflix',
        amount: 15.99,
        recurrentInfo: 'monthly',
        createdAt: now,
        syncStatus: SyncStatus.synced,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 're-1');
      expect(companion.coupleId.value, 'couple-1');
      expect(companion.createdBy.value, 'user-1');
      expect(companion.name.value, 'Netflix');
      expect(companion.amount.value, 15.99);
      expect(companion.recurrentInfo.value, 'monthly');
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });
  });
}
