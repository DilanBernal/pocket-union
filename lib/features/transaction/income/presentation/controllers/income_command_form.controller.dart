import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pocket_union/features/transaction/application/dto/income_ins_dto.dart';
import 'package:pocket_union/features/transaction/application/services/income_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'income_command_form.controller.g.dart';

@riverpod
class IncomeCommandFormController extends _$IncomeCommandFormController {
  @override
  AsyncValue build() => const AsyncData(null);

  late String primaryCategoryId;

  Future<void> submit(FormBuilderState formState) async {
    if (formState.saveAndValidate() == false) {
      state = AsyncError('Validation failed', StackTrace.current);
      return;
    }
    final formData = formState.value;
    final incomeService = await ref.read(incomeServiceProvider.future);
    incomeService.createIncome(
      IncomeInsDto(
        amount: formData['amount'],
        name: formData['name'],
        description: formData['description'],
        recipient: formData['recipient'],
        categoryIds: formData['categoryIds'] ?? [],
        primaryCategoryId: primaryCategoryId,
      ),
    );
  }
}
