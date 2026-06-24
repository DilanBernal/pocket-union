import 'package:drift/drift.dart';

import '../../../domain/enum/sync_status.dart';
import '../../../domain/models/recurrent_income.dart';
import '../app_database.dart' as drift;

class RecurrentIncomeMapper {
  RecurrentIncome toDomain(drift.RecurrentIncome data) {
    return RecurrentIncome(
      id: data.id,
      coupleId: data.coupleId,
      name: data.name,
      amount: data.amount,
      userRecipientId: data.userRecipientId,
      recurrentInfo: data.recurrentInfo,
      createdAt: data.createdAt,
      syncStatus: SyncStatus.fromString(
        (data.syncStatus).toUpperCase(),
      ),
    );
  }

  drift.RecurrentIncomesCompanion toCompanion(RecurrentIncome income) {
    final now = DateTime.now().toUtc();
    return drift.RecurrentIncomesCompanion.insert(
      id: income.id,
      coupleId: income.coupleId,
      userRecipientId: Value(income.userRecipientId),
      name: income.name,
      amount: income.amount,
      recurrentInfo: Value(income.recurrentInfo),
      createdAt: Value(income.createdAt),
      syncStatus: Value(income.syncStatus.value.toLowerCase()),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
  }
}
