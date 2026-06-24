import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/couple_mapper.dart';
import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/domain/models/couple.dart';

void main() {
  final mapper = CoupleMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('CoupleMapper.toDomain', () {
    test('convierte Drift Couple a Couple de dominio con todos los campos', () {
      final driftCouple = drift.Couple(
        id: 'couple-1',
        user1Id: 'user-1',
        user2Id: 'user-2',
        inviteCode: 'ABC123',
        isUsable: 'READY',
        createdAt: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftCouple);

      expect(domain.id, 'couple-1');
      expect(domain.user1Id, 'user-1');
      expect(domain.user2Id, 'user-2');
      expect(domain.inviteCode, 'ABC123');
      expect(domain.isUsable, CoupleUsableState.ready);
      expect(domain.createdAt, now);
    });

    test('isUsable "WAITING" se mapea correctamente', () {
      final driftCouple = drift.Couple(
        id: 'couple-2',
        isUsable: 'WAITING',
        createdAt: now,
        syncStatus: 'synced',
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftCouple);

      expect(domain.isUsable, CoupleUsableState.waiting);
    });

    test('isUsable "CANCELED" se mapea correctamente', () {
      final driftCouple = drift.Couple(
        id: 'couple-3',
        isUsable: 'CANCELED',
        createdAt: now,
        syncStatus: 'synced',
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftCouple);

      expect(domain.isUsable, CoupleUsableState.canceled);
    });

    test('campos opcionales nulos son null en dominio', () {
      final driftCouple = drift.Couple(
        id: 'couple-4',
        isUsable: 'WAITING',
        createdAt: now,
        syncStatus: 'synced',
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftCouple);

      expect(domain.user1Id, isNull);
      expect(domain.user2Id, isNull);
      expect(domain.inviteCode, isNull);
    });
  });

  group('CoupleMapper.toCompanion', () {
    test('convierte Couple de dominio a CouplesCompanion', () {
      final domain = Couple(
        id: 'couple-1',
        createdAt: now,
        user1Id: 'user-1',
        user2Id: 'user-2',
        inviteCode: 'ABC123',
        isUsable: CoupleUsableState.waiting,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'couple-1');
      expect(companion.user1Id.value, 'user-1');
      expect(companion.user2Id.value, 'user-2');
      expect(companion.inviteCode.value, 'ABC123');
      expect(companion.isUsable.value, 'WAITING');
      expect(companion.createdAt.value, now);
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });
  });
}
