import 'package:drift/drift.dart';

import '../../../domain/models/auth/user.dart';
import '../app_database.dart';

class UserMapper {
  DomainUser toDomain(Profile data) {
    return DomainUser(
      id: data.id,
      fullName: data.fullName ?? '',
      balance: data.userBalance,
      avatarUrl: data.avatarUrl,
      lastSync: data.lastSync,
      inCloud: data.inCloud,
    );
  }

  ProfilesCompanion toCompanion(DomainUser user) {
    final now = DateTime.now().toUtc();
    return ProfilesCompanion.insert(
      id: user.id,
      fullName: Value(user.fullName),
      avatarUrl: Value(user.avatarUrl),
      userBalance: Value(user.balance),
      inCloud: Value(user.inCloud),
      updatedAt: Value(now),
      lastSync: Value(user.lastSync),
      syncStatus: const Value('synced'),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
  }
}
