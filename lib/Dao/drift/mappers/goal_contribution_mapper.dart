import 'package:drift/drift.dart';

import '../../../domain/models/goal_contribution.dart';
import '../app_database.dart' as drift;

class GoalContributionMapper {
  GoalContribution toDomain(drift.GoalContribution data) {
    return GoalContribution(
      id: data.id,
      goalId: data.goalId,
      userId: data.userId,
      amount: data.amount,
      contributionDate: data.contributionDate,
      createdAt: data.createdAt,
      inCloud: data.syncStatus == 'synced',
    );
  }

  drift.GoalContributionsCompanion toCompanion(GoalContribution contribution) {
    final now = DateTime.now().toUtc();
    return drift.GoalContributionsCompanion.insert(
      id: contribution.id,
      goalId: contribution.goalId,
      userId: contribution.userId,
      amount: Value(contribution.amount),
      contributionDate: Value(contribution.contributionDate),
      createdAt: Value(contribution.createdAt),
      syncStatus: Value(contribution.inCloud ? 'synced' : 'pending'),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
  }
}
