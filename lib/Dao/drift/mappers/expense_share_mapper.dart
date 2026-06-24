import 'package:drift/drift.dart';

import '../../../domain/models/expense_share.dart';
import '../app_database.dart' as drift;

class ExpenseShareMapper {
  ExpenseShare toDomain(drift.ExpenseShare data) {
    return ExpenseShare(
      id: data.id,
      createdAt: data.createdAt,
      expenseId: data.expenseId,
      userId: data.userId,
      sharePercentage: data.sharePercentage,
      inCloud: data.syncStatus == 'synced',
    );
  }

  drift.ExpenseSharesCompanion toCompanion(ExpenseShare share) {
    final now = DateTime.now().toUtc();
    return drift.ExpenseSharesCompanion.insert(
      id: share.id,
      createdAt: Value(share.createdAt),
      expenseId: share.expenseId,
      userId: share.userId,
      sharePercentage: share.sharePercentage,
      syncStatus: Value(share.inCloud ? 'synced' : 'pending'),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
  }
}
