import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/expense_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/expense.dart';

void main() {
  final mapper = ExpenseMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('ExpenseMapper.toDomain', () {
    test('convierte Drift Expense a Expense de dominio con todos los campos', () {
      final driftExpense = drift.Expense(
        id: 'exp-1',
        coupleId: 'couple-1',
        amount: 150.0,
        description: 'Cena',
        categoryId: 'cat-1',
        transactionDate: now,
        isFixed: false,
        importanceLevel: 2,
        isPlaned: true,
        createdAt: now,
        createdBy: 'user-1',
        name: 'Restaurante',
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftExpense);

      expect(domain.id, 'exp-1');
      expect(domain.coupleId, 'couple-1');
      expect(domain.amount, 150.0);
      expect(domain.description, 'Cena');
      expect(domain.categoryIds, ['cat-1']);
      expect(domain.transactionDate, now);
      expect(domain.isFixed, false);
      expect(domain.importanceLevel, 2);
      expect(domain.isPlaned, true);
      expect(domain.createdAt, now);
      expect(domain.createdBy, 'user-1');
      expect(domain.name, 'Restaurante');
      expect(domain.syncStatus, SyncStatus.synced);
      expect(domain.isDeleted, false);
    });

    test('categoryId null mapea a categoryIds vacío', () {
      final driftExpense = drift.Expense(
        id: 'exp-2',
        coupleId: 'couple-1',
        amount: 50.0,
        createdAt: now,
        createdBy: 'user-1',
        name: 'Café',
        syncStatus: 'pending',
        isDeleted: false,
        isFixed: false,
        importanceLevel: 0,
        isPlaned: false,
      );

      final domain = mapper.toDomain(driftExpense);

      expect(domain.categoryIds, isEmpty);
    });

    test('syncStatus "pending" se mapea correctamente', () {
      final driftExpense = drift.Expense(
        id: 'exp-3',
        coupleId: 'couple-1',
        amount: 25.0,
        createdAt: now,
        createdBy: 'user-1',
        name: 'Taxi',
        syncStatus: 'pending',
        isDeleted: false,
        isFixed: false,
        importanceLevel: 0,
        isPlaned: false,
      );

      final domain = mapper.toDomain(driftExpense);

      expect(domain.syncStatus, SyncStatus.pending);
    });
  });

  group('ExpenseMapper.toCompanion', () {
    test('convierte Expense de dominio a ExpensesCompanion', () {
      final domain = Expense(
        id: 'exp-1',
        coupleId: 'couple-1',
        createdBy: 'user-1',
        name: 'Supermercado',
        amount: 200.0,
        categoryIds: ['cat-1'],
        isFixed: true,
        importanceLevel: 3,
        isPlaned: false,
        createdAt: now,
        syncStatus: SyncStatus.synced,
        localUpdatedAt: now,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'exp-1');
      expect(companion.coupleId.value, 'couple-1');
      expect(companion.amount.value, 200.0);
      expect(companion.categoryId.value, 'cat-1');
      expect(companion.isFixed.value, true);
      expect(companion.importanceLevel.value, 3);
      expect(companion.isPlaned.value, false);
      expect(companion.createdBy.value, 'user-1');
      expect(companion.name.value, 'Supermercado');
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });

    test('categoryIds vacío resulta en categoryId null', () {
      final domain = Expense(
        id: 'exp-2',
        coupleId: 'couple-1',
        createdBy: 'user-1',
        name: 'Compra',
        amount: 100.0,
        categoryIds: [],
        importanceLevel: 0,
        createdAt: now,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.categoryId.value, isNull);
    });
  });

  group('ExpenseMapper roundtrip', () {
    test('domain -> companion -> toDomain preserva campos clave', () {
      final original = Expense(
        id: 'exp-roundtrip',
        coupleId: 'couple-1',
        createdBy: 'user-1',
        name: 'Gasolina',
        transactionDate: now,
        description: 'Llenar tanque',
        amount: 45.0,
        categoryIds: ['cat-2'],
        isFixed: false,
        importanceLevel: 1,
        isPlaned: true,
        createdAt: now,
        syncStatus: SyncStatus.pending,
        localUpdatedAt: now,
      );

      final companion = mapper.toCompanion(original);

      expect(companion.id.value, original.id);
      expect(companion.coupleId.value, original.coupleId);
      expect(companion.amount.value, original.amount);
      expect(companion.name.value, original.name);
      expect(companion.createdBy.value, original.createdBy);
      expect(companion.description.value, original.description);
    });
  });
}
