import 'package:drift/drift.dart';

import '../../../domain/models/goal.dart';
import '../app_database.dart' as drift;

class GoalMapper {
  Goal toDomain(drift.Goal data) {
    return Goal(
      id: data.id,
      createdAt: data.createdAt,
      coupleId: data.coupleId,
      name: data.name,
      targetAmount: data.targetAmount,
      currentAmount: data.currentAmount,
      deadline: data.deadline,
      description: data.description,
      inCloud: data.syncStatus == 'synced',
    );
  }

  drift.GoalsCompanion toCompanion(Goal goal) {
    final now = DateTime.now().toUtc();
    return drift.GoalsCompanion.insert(
      id: goal.id,
      createdAt: Value(goal.createdAt),
      coupleId: goal.coupleId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: Value(goal.currentAmount),
      deadline: Value(goal.deadline),
      description: Value(goal.description),
      syncStatus: Value(goal.inCloud ? 'synced' : 'pending'),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
  }
}
