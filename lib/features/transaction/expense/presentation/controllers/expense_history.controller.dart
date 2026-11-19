import 'dart:async';

import 'package:pocket_union/features/transaction/application/services/expense_service.dart';
import 'package:pocket_union/features/transaction/domain/entities/expense_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_history.controller.g.dart';

@riverpod
class ExpenseHistoryController extends _$ExpenseHistoryController {
  @override
  AsyncValue<List<ExpenseEntity>> build() {
    unawaited(_initialize());
    return const AsyncLoading();
  }

  Future<void> _initialize() async {
    final service = await ref.read(expenseServiceProvider.future);
    try {
      final localExpenses = await service.getLocalExpenses();
      state = AsyncData(localExpenses);
      await service.synchronizeExpenses();
      if (!ref.mounted) return;
      state = AsyncData(await service.getLocalExpenses());
    } catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  Future<void> refresh() async {
    final service = await ref.read(expenseServiceProvider.future);
    await service.synchronizeExpenses();
    if (!ref.mounted) return;
    state = AsyncData(await service.getLocalExpenses());
  }
}
