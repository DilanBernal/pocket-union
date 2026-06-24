import 'package:drift/drift.dart';

import '../../../domain/enum/sync_status.dart';
import '../../../domain/models/expense.dart';
import '../app_database.dart' as drift;

class ExpenseMapper {
  Expense toDomain(drift.Expense data) {
    return Expense(
      id: data.id,
      coupleId: data.coupleId,
      createdBy: data.createdBy,
      name: data.name,
      transactionDate: data.transactionDate,
      description: data.description,
      amount: data.amount,
      categoryIds: data.categoryId != null ? [data.categoryId!] : [],
      isFixed: data.isFixed,
      importanceLevel: data.importanceLevel,
      isPlaned: data.isPlaned,
      createdAt: data.createdAt,
      syncStatus: SyncStatus.fromString(
        (data.syncStatus).toUpperCase(),
      ),
      localUpdatedAt: data.localUpdatedAt,
      isDeleted: data.isDeleted,
    );
  }

  drift.ExpensesCompanion toCompanion(Expense expense) {
    final now = DateTime.now().toUtc();
    return drift.ExpensesCompanion.insert(
      id: expense.id,
      coupleId: expense.coupleId,
      amount: expense.amount,
      description: Value(expense.description),
      categoryId: Value(expense.categoryIds.isNotEmpty
          ? expense.categoryIds.first
          : null),
      transactionDate: Value(expense.transactionDate),
      isFixed: Value(expense.isFixed),
      importanceLevel: Value(expense.importanceLevel),
      isPlaned: Value(expense.isPlaned),
      createdAt: Value(expense.createdAt),
      createdBy: expense.createdBy,
      name: expense.name,
      syncStatus: Value(expense.syncStatus.value.toLowerCase()),
      localUpdatedAt: Value(now),
      isDeleted: Value(expense.isDeleted),
    );
  }
}
