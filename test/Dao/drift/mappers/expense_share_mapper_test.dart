import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/expense_share_mapper.dart';
import 'package:pocket_union/domain/models/expense_share.dart';

void main() {
  final mapper = ExpenseShareMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('ExpenseShareMapper.toDomain', () {
    test('convierte Drift ExpenseShare a ExpenseShare de dominio', () {
      final driftShare = drift.ExpenseShare(
        id: 'share-1',
        expenseId: 'exp-1',
        userId: 'user-1',
        sharePercentage: 50.0,
        createdAt: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftShare);

      expect(domain.id, 'share-1');
      expect(domain.expenseId, 'exp-1');
      expect(domain.userId, 'user-1');
      expect(domain.sharePercentage, 50.0);
      expect(domain.createdAt, now);
      expect(domain.inCloud, true);
    });

    test('syncStatus "pending" mapea inCloud a false', () {
      final driftShare = drift.ExpenseShare(
        id: 'share-2',
        expenseId: 'exp-1',
        userId: 'user-2',
        sharePercentage: 50.0,
        createdAt: now,
        syncStatus: 'pending',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftShare);

      expect(domain.inCloud, false);
    });
  });

  group('ExpenseShareMapper.toCompanion', () {
    test('convierte ExpenseShare de dominio a ExpenseSharesCompanion', () {
      final domain = ExpenseShare(
        id: 'share-1',
        expenseId: 'exp-1',
        userId: 'user-1',
        sharePercentage: 50.0,
        createdAt: now,
        inCloud: true,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'share-1');
      expect(companion.expenseId.value, 'exp-1');
      expect(companion.userId.value, 'user-1');
      expect(companion.sharePercentage.value, 50.0);
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });

    test('inCloud false mapea a syncStatus "pending"', () {
      final domain = ExpenseShare(
        id: 'share-2',
        expenseId: 'exp-1',
        userId: 'user-2',
        sharePercentage: 100.0,
        createdAt: now,
        inCloud: false,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.syncStatus.value, 'pending');
    });
  });
}
