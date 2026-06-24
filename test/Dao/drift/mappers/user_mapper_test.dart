import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/user_mapper.dart';
import 'package:pocket_union/domain/models/auth/user.dart';

void main() {
  final mapper = UserMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('UserMapper.toDomain', () {
    test('convierte Profile a DomainUser con todos los campos', () {
      final profile = drift.Profile(
        id: 'user-1',
        fullName: 'Juan Pérez',
        avatarUrl: 'https://example.com/avatar.jpg',
        userBalance: 5000.0,
        inCloud: true,
        updatedAt: now,
        lastSync: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(profile);

      expect(domain.id, 'user-1');
      expect(domain.fullName, 'Juan Pérez');
      expect(domain.avatarUrl, 'https://example.com/avatar.jpg');
      expect(domain.balance, 5000.0);
      expect(domain.inCloud, true);
      expect(domain.lastSync, now);
    });

    test('fullName null en Profile se mapea a string vacío', () {
      final profile = drift.Profile(
        id: 'user-2',
        userBalance: 0.0,
        inCloud: false,
        syncStatus: 'synced',
        isDeleted: false,
      );

      final domain = mapper.toDomain(profile);

      expect(domain.fullName, '');
    });

    test('avatarUrl y lastSync nulos se reflejan en dominio', () {
      final profile = drift.Profile(
        id: 'user-3',
        userBalance: 100.0,
        inCloud: false,
        syncStatus: 'pending',
        isDeleted: false,
      );

      final domain = mapper.toDomain(profile);

      expect(domain.avatarUrl, isNull);
      expect(domain.lastSync, isNull);
    });
  });

  group('UserMapper.toCompanion', () {
    test('convierte DomainUser a ProfilesCompanion', () {
      final domain = DomainUser(
        id: 'user-1',
        fullName: 'Juan Pérez',
        balance: 5000.0,
        avatarUrl: 'https://example.com/avatar.jpg',
        lastSync: now,
        inCloud: true,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'user-1');
      expect(companion.fullName.value, 'Juan Pérez');
      expect(companion.userBalance.value, 5000.0);
      expect(companion.avatarUrl.value, 'https://example.com/avatar.jpg');
      expect(companion.inCloud.value, true);
      expect(companion.lastSync.value, now);
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });
  });
}
