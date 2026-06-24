import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/income_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/income.dart';

void main() {
  final mapper = IncomeMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('IncomeMapper.toDomain', () {
    test('convierte Drift Income a Income de dominio con todos los campos', () {
      final driftIncome = drift.Income(
        id: 'inc-1',
        coupleId: 'couple-1',
        amount: 3000.0,
        description: 'Sueldo mensual',
        categoryId: 'cat-1',
        transactionDate: now,
        isRecurring: false,
        recurrenceInterval: null,
        isReceived: true,
        receivedIn: null,
        createdAt: now,
        name: 'Salario',
        userRecipientId: 'user-1',
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftIncome);

      expect(domain.id, 'inc-1');
      expect(domain.coupleId, 'couple-1');
      expect(domain.amount, 3000.0);
      expect(domain.description, 'Sueldo mensual');
      expect(domain.categoryIds, ['cat-1']);
      expect(domain.transactionDate, now);
      expect(domain.isRecurring, false);
      expect(domain.isReceived, true);
      expect(domain.name, 'Salario');
      expect(domain.userRecipientId, 'user-1');
      expect(domain.syncStatus, SyncStatus.synced);
      expect(domain.isDeleted, false);
    });

    test('categoryId null mapea a categoryIds vacío', () {
      final driftIncome = drift.Income(
        id: 'inc-2',
        amount: 500.0,
        transactionDate: now,
        createdAt: now,
        name: 'Bono',
        syncStatus: 'pending',
        isDeleted: false,
        isRecurring: false,
        isReceived: true,
      );

      final domain = mapper.toDomain(driftIncome);

      expect(domain.categoryIds, isEmpty);
    });

    test('syncStatus se mapea correctamente', () {
      final driftIncome = drift.Income(
        id: 'inc-3',
        amount: 100.0,
        transactionDate: now,
        createdAt: now,
        name: 'Interés',
        syncStatus: 'pending',
        isDeleted: false,
        isRecurring: false,
        isReceived: true,
      );

      final domain = mapper.toDomain(driftIncome);

      expect(domain.syncStatus, SyncStatus.pending);
    });
  });

  group('IncomeMapper.toCompanion', () {
    test('convierte Income de dominio a IncomesCompanion', () {
      final domain = Income(
        id: 'inc-1',
        coupleId: 'couple-1',
        name: 'Salario',
        transactionDate: now,
        amount: 3000.0,
        categoryIds: ['cat-1'],
        isRecurring: false,
        isReceived: true,
        createdAt: now,
        userRecipientId: 'user-1',
        syncStatus: SyncStatus.synced,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'inc-1');
      expect(companion.name.value, 'Salario');
      expect(companion.amount.value, 3000.0);
      expect(companion.categoryId.value, 'cat-1');
      expect(companion.transactionDate.value, now);
      expect(companion.isRecurring.value, false);
      expect(companion.isReceived.value, true);
      expect(companion.userRecipientId.value, 'user-1');
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });

    test('categoryIds vacío resulta en categoryId null', () {
      final domain = Income(
        id: 'inc-2',
        name: 'Regalo',
        transactionDate: now,
        amount: 50.0,
        categoryIds: [],
        createdAt: now,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.categoryId.value, isNull);
    });

    test('coupleId null en dominio se refleja en companion', () {
      final domain = Income(
        id: 'inc-3',
        name: 'Venta',
        transactionDate: now,
        amount: 200.0,
        createdAt: now,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.coupleId.value, isNull);
    });
  });
}
