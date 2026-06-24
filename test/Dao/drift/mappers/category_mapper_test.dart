import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/category_mapper.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';

void main() {
  final mapper = CategoryMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('CategoryMapper.toDomain', () {
    test('convierte Drift Category a Category de dominio con todos los campos', () {
      final driftCategory = drift.Category(
        id: 'cat-1',
        name: 'Comida',
        coupleId: 'couple-1',
        icon: 'food',
        shortDescription: 'Gastos en comida',
        color: '#FF5733',
        categoryHost: 'expense',
        createdAt: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftCategory);

      expect(domain.id, 'cat-1');
      expect(domain.name, 'Comida');
      expect(domain.coupleId, 'couple-1');
      expect(domain.icon, 'food');
      expect(domain.shortDescription, 'Gastos en comida');
      expect(domain.color, '#FF5733');
      expect(domain.categoryHost, CategoryHost.expense);
      expect(domain.syncStatus, SyncStatus.synced);
      expect(domain.createdAt, now);
      expect(domain.localUpdatedAt, now);
    });

    test('convierte con valores nulos opcionales', () {
      final driftCategory = drift.Category(
        id: 'cat-2',
        name: 'Salario',
        coupleId: 'couple-1',
        categoryHost: 'INCOME',
        createdAt: now,
        syncStatus: 'pending',
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftCategory);

      expect(domain.id, 'cat-2');
      expect(domain.icon, isNull);
      expect(domain.shortDescription, isNull);
      expect(domain.color, isNull);
      expect(domain.categoryHost, CategoryHost.income);
      expect(domain.syncStatus, SyncStatus.pending);
    });

    test('syncStatus "synced" se mapea correctamente', () {
      final driftCategory = drift.Category(
        id: 'cat-3',
        name: 'Transporte',
        coupleId: 'couple-1',
        categoryHost: 'expense',
        createdAt: now,
        syncStatus: 'synced',
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftCategory);

      expect(domain.syncStatus, SyncStatus.synced);
    });
  });

  group('CategoryMapper.toCompanion', () {
    test('convierte Category de dominio a CategoriesCompanion', () {
      final domain = Category(
        id: 'cat-1',
        coupleId: 'couple-1',
        name: 'Comida',
        icon: 'food',
        shortDescription: 'Gastos en comida',
        color: '#FF5733',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.synced,
        localUpdatedAt: now,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'cat-1');
      expect(companion.name.value, 'Comida');
      expect(companion.coupleId.value, 'couple-1');
      expect(companion.icon.value, 'food');
      expect(companion.shortDescription.value, 'Gastos en comida');
      expect(companion.color.value, '#FF5733');
      expect(companion.categoryHost.value, 'EXPENSE');
      expect(companion.createdAt.value, now);
      expect(companion.syncStatus.value, 'synced');
      expect(companion.localUpdatedAt.value, now);
      expect(companion.isDeleted.value, false);
    });

    test('toCompanion asigna SyncStatus.pending como "pending"', () {
      final domain = Category(
        id: 'cat-2',
        coupleId: 'couple-1',
        name: 'Freelance',
        createdAt: now,
        categoryHost: CategoryHost.income,
        syncStatus: SyncStatus.pending,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.syncStatus.value, 'pending');
    });

    test('toCompanion asigna SyncStatus.synced como "synced"', () {
      final domain = Category(
        id: 'cat-3',
        coupleId: 'couple-1',
        name: 'Sueldo',
        createdAt: now,
        categoryHost: CategoryHost.income,
        syncStatus: SyncStatus.synced,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.syncStatus.value, 'synced');
    });
  });

  group('CategoryMapper roundtrip', () {
    test('domain -> companion -> domain preserva datos', () {
      final original = Category(
        id: 'cat-roundtrip',
        coupleId: 'couple-1',
        name: 'Ocio',
        icon: 'game',
        shortDescription: 'Entretenimiento',
        color: '#00FF00',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.synced,
        localUpdatedAt: now,
      );

      final companion = mapper.toCompanion(original);

      expect(companion.id.value, original.id);
      expect(companion.name.value, original.name);
      expect(companion.coupleId.value, original.coupleId);
      expect(companion.icon.value, original.icon);
      expect(companion.shortDescription.value, original.shortDescription);
      expect(companion.color.value, original.color);
      expect(companion.categoryHost.value, original.categoryHost.value);
      expect(companion.createdAt.value, original.createdAt);
    });
  });
}
