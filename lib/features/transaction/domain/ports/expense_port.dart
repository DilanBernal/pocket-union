import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/transaction/application/dto/expense_ins_dto.dart';
import 'package:pocket_union/features/transaction/domain/entities/expense_entity.dart';

abstract class ExpensePort {
  Future<AppResponse<String?>> createExpense(ExpenseInsDto data);
  Future<List<ExpenseEntity>> getLocalExpenses();
  Future<void> synchronizeExpenses();
  Future<AppResponse<bool>> deleteExpense(String id);
}
