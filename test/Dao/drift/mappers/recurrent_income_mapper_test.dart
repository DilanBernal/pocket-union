import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/recurrent_income_mapper.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/recurrent_income.dart';

void main() {
  final mapper = RecurrentIncomeMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('RecurrentIncomeMapper.toDomain', () {
    test('convierte Drift RecurrentIncome a RecurrentIncome de dominio', () {
      final driftIncome = drift.RecurrentIncome(
        id: 'ri-1',
        coupleId: 'couple-1',
        userRecipientId: 'user-1',
        name: 'Alquiler',
        amount: 1200.0,
        recurrentInfo: 'monthly',
        createdAt: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftIncome);

      expect(domain.id, 'ri-1');
      expect(domain.coupleId, 'couple-1');
      expect(domain.userRecipientId, 'user-1');
      expect(domain.name, 'Alquiler');
      expect(domain.amount, 1200.0);
      expect(domain.recurrentInfo, 'monthly');
      expect(domain.createdAt, now);
      expect(domain.syncStatus, SyncStatus.synced);
    });
  });

  group('RecurrentIncomeMapper.toCompanion', () {
    test('convierte RecurrentIncome de dominio a RecurrentIncomesCompanion', () {
      final domain = RecurrentIncome(
        id: 'ri-1',
        coupleId: 'couple-1',
        userRecipientId: 'user-1',
        name: 'Alquiler',
        amount: 1200.0,
        recurrentInfo: 'monthly',
        createdAt: now,
        syncStatus: SyncStatus.synced,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'ri-1');
      expect(companion.coupleId.value, 'couple-1');
      expect(companion.userRecipientId.value, 'user-1');
      expect(companion.name.value, 'Alquiler');
      expect(companion.amount.value, 1200.0);
      expect(companion.recurrentInfo.value, 'monthly');
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });
  });
}
