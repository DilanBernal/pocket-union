import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/transaction/application/dto/expense_ins_dto.dart';

abstract class ExpensePort {
  Future<AppResponse<String?>> createExpense(ExpenseInsDto data);
}
