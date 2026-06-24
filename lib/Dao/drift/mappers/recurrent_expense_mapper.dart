import 'package:drift/drift.dart';

import '../../../domain/enum/sync_status.dart';
import '../../../domain/models/recurrent_expense.dart';
import '../app_database.dart' as drift;

class RecurrentExpenseMapper {
  RecurrentExpense toDomain(drift.RecurrentExpense data) {
    return RecurrentExpense(
      id: data.id,
      coupleId: data.coupleId,
      createdBy: data.createdBy ?? '',
      name: data.name,
      amount: data.amount,
      recurrentInfo: data.recurrentInfo,
      createdAt: data.createdAt,
      syncStatus: SyncStatus.fromString(
        (data.syncStatus).toUpperCase(),
      ),
    );
  }

  drift.RecurrentExpensesCompanion toCompanion(RecurrentExpense expense) {
    final now = DateTime.now().toUtc();
    return drift.RecurrentExpensesCompanion.insert(
      id: expense.id,
      coupleId: expense.coupleId,
      createdBy: Value(expense.createdBy),
      name: expense.name,
      amount: expense.amount,
      recurrentInfo: Value(expense.recurrentInfo),
      createdAt: Value(expense.createdAt),
      syncStatus: Value(expense.syncStatus.value.toLowerCase()),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
  }
}
