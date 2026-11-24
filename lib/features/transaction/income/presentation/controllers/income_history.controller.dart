import 'dart:async';

import 'package:pocket_union/features/transaction/application/services/income_service.dart';
import 'package:pocket_union/features/transaction/domain/entities/income_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'income_history.controller.g.dart';

@riverpod
class IncomeHistoryController extends _$IncomeHistoryController {
  @override
  AsyncValue<List<IncomeEntity>> build() {
    unawaited(_initialize());
    return const AsyncLoading();
  }

  Future<void> _initialize() async {
    final service = await ref.read(incomeServiceProvider.future);
    try {
      final localIncomes = await service.getLocalIncomes();
      state = AsyncData(localIncomes);
      await service.synchronizeIncomes();
      if (!ref.mounted) return;
      state = AsyncData(await service.getLocalIncomes());
    } catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  Future<void> refresh() async {
    final service = await ref.read(incomeServiceProvider.future);
    await service.synchronizeIncomes();
    if (!ref.mounted) return;
    state = AsyncData(await service.getLocalIncomes());
  }
}
