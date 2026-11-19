import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/transaction/application/dto/expense_ins_dto.dart';
import 'package:pocket_union/features/transaction/application/services/expense_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_command_form.controller.g.dart';

@riverpod
class ExpenseCommandFormController extends _$ExpenseCommandFormController {
  @override
  AsyncValue build() => const AsyncData(null);

  final primaryCategoryId = ValueNotifier<CategoryEntity?>(null);

  Future<void> submit(FormBuilderState formState) async {
    if (!formState.saveAndValidate()) {
      state = AsyncError('Validation failed', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      final formData = formState.value;
      final expenseService = await ref.read(expenseServiceProvider.future);
      final amount = formData['amount'];
      if (amount is! num) {
        state = AsyncError('Invalid amount', StackTrace.current);
        return;
      }

      final response = await expenseService.createExpense(
        ExpenseInsDto(
          amount: amount.toDouble(),
          name: formData['name'] as String,
          description: formData['description'] as String?,
          transactionDate: formData['date'] as DateTime?,
          categoryIds: List<String>.from(formData['categories'] ?? const []),
          primaryCategoryId: primaryCategoryId.value?.id,
          importanceLevel: formData['importance_level'] as int,
          isPaid: formData['is_paid'] as bool,
        ),
      );

      if (response is Success<String?>) {
        state = AsyncData(response.value);
      } else if (response is Failure<String?>) {
        state = AsyncError(response.error, StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
