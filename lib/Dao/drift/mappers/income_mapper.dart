import 'package:drift/drift.dart';

import '../../../domain/enum/sync_status.dart';
import '../../../domain/models/income.dart';
import '../app_database.dart' as drift;

class IncomeMapper {
  Income toDomain(drift.Income data) {
    return Income(
      id: data.id,
      coupleId: data.coupleId,
      name: data.name,
      transactionDate: data.transactionDate,
      description: data.description,
      amount: data.amount,
      categoryIds: data.categoryId != null ? [data.categoryId!] : [],
      isRecurring: data.isRecurring,
      isReceived: data.isReceived,
      receivedIn: data.receivedIn != null ? _parseJson(data.receivedIn!) : null,
      createdAt: data.createdAt,
      userRecipientId: data.userRecipientId,
      syncStatus: SyncStatus.fromString(
        (data.syncStatus).toUpperCase(),
      ),
      isDeleted: data.isDeleted,
    );
  }

  drift.IncomesCompanion toCompanion(Income income) {
    final now = DateTime.now().toUtc();
    return drift.IncomesCompanion.insert(
      id: income.id,
      coupleId: Value(income.coupleId),
      amount: income.amount,
      description: Value(income.description),
      categoryId: Value(income.categoryIds.isNotEmpty
          ? income.categoryIds.first
          : null),
      transactionDate: income.transactionDate,
      isRecurring: Value(income.isRecurring),
      recurrenceInterval: const Value(null),
      isReceived: Value(income.isReceived),
      receivedIn: Value(income.receivedIn?.toString()),
      createdAt: Value(income.createdAt),
      name: income.name,
      userRecipientId: Value(income.userRecipientId),
      syncStatus: Value(income.syncStatus.value.toLowerCase()),
      localUpdatedAt: Value(now),
      isDeleted: Value(income.isDeleted),
    );
  }

  Map<String, dynamic>? _parseJson(String raw) {
    try {
      return Map<String, dynamic>.from(
        Uri.splitQueryString(raw.substring(1, raw.length - 1)),
      );
    } catch (_) {
      return null;
    }
  }
}
