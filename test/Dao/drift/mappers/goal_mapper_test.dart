import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/goal_mapper.dart';
import 'package:pocket_union/domain/models/goal.dart';

void main() {
  final mapper = GoalMapper();
  final now = DateTime(2024, 6, 1, 12, 0, 0);
  final deadline = DateTime(2025, 1, 1);

  group('GoalMapper.toDomain', () {
    test('convierte Drift Goal a Goal de dominio con todos los campos', () {
      final driftGoal = drift.Goal(
        id: 'goal-1',
        coupleId: 'couple-1',
        name: 'Ahorro viaje',
        targetAmount: 5000.0,
        currentAmount: 1500.0,
        deadline: deadline,
        description: 'Viaje a Japón',
        createdAt: now,
        syncStatus: 'synced',
        localUpdatedAt: now,
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftGoal);

      expect(domain.id, 'goal-1');
      expect(domain.coupleId, 'couple-1');
      expect(domain.name, 'Ahorro viaje');
      expect(domain.targetAmount, 5000.0);
      expect(domain.currentAmount, 1500.0);
      expect(domain.deadline, deadline);
      expect(domain.description, 'Viaje a Japón');
      expect(domain.createdAt, now);
      expect(domain.inCloud, true);
    });

    test('syncStatus "pending" mapea inCloud a false', () {
      final driftGoal = drift.Goal(
        id: 'goal-2',
        coupleId: 'couple-1',
        name: 'Fondo emergencia',
        targetAmount: 10000.0,
        currentAmount: 0.0,
        createdAt: now,
        syncStatus: 'pending',
        isDeleted: false,
      );

      final domain = mapper.toDomain(driftGoal);

      expect(domain.inCloud, false);
    });
  });

  group('GoalMapper.toCompanion', () {
    test('convierte Goal de dominio a GoalsCompanion', () {
      final domain = Goal(
        id: 'goal-1',
        coupleId: 'couple-1',
        name: 'Ahorro viaje',
        targetAmount: 5000.0,
        currentAmount: 1500.0,
        deadline: deadline,
        description: 'Viaje a Japón',
        createdAt: now,
        inCloud: true,
      );

      final companion = mapper.toCompanion(domain);

      expect(companion.id.value, 'goal-1');
      expect(companion.coupleId.value, 'couple-1');
      expect(companion.name.value, 'Ahorro viaje');
      expect(companion.targetAmount.value, 5000.0);
      expect(companion.currentAmount.value, 1500.0);
      expect(companion.deadline.value, deadline);
      expect(companion.description.value, 'Viaje a Japón');
      expect(companion.syncStatus.value, 'synced');
      expect(companion.isDeleted.value, false);
    });
  });
}
