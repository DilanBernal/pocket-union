import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/goal_contribution_mapper.dart';
import 'package:pocket_union/domain/models/goal_contribution.dart';

void main() {
  final mapper = GoalContributionMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);

  group('GoalContributionMapper.toDomain', () {
    test('convierte Drift GoalContribution a GoalContribution de dominio', () {
      final driftContribution = drift.GoalContribution(
        id: 'contrib-1',
        goalId: 'goal-1',
        userId: 'user-1',
        amount: 500.0,
        contributionDate: now,
        createdAt: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftContribution);

      expect(domain.id, 'contrib-1');
      expect(domain.goalId, 'goal-1');
      expect(domain.userId, 'user-1');
      expect(domain.amount, 500.0);
      expect(domain.contributionDate, now);
      expect(domain.createdAt, now);
      expect(domain.inCloud, true);
    });

    test('syncStatus "pending" mapea inCloud a false', () {
      final driftContribution = drift.GoalContribution(
        id: 'contrib-2',
        goalId: 'goal-1',
        userId: 'user-1',
        amount: 200.0,
        contributionDate: now,
        createdAt: now,
        syncStatus: 'pending',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftContribution);

      expect(domain.inCloud, false);
    });
  });

  group('GoalContributionMapper.toCompanion', () {
    test('convierte GoalContribution de dominio a GoalContributionsCompanion', () {
      final domain = GoalContribution(
        id: 'contrib-1',
        goalId: 'goal-1',
        userId: 'user-1',
        amount: 500.0,
        contributionDate: now,
        createdAt: now,
        inCloud: true,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'contrib-1');
      expect(companion.goalId.value, 'goal-1');
      expect(companion.userId.value, 'user-1');
      expect(companion.amount.value, 500.0);
      expect(companion.contributionDate.value, now);
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });
  });
}
