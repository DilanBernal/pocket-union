import 'package:pocket_union/domain/models/expense_share.dart';

abstract class IExpenseSharePort {
  Future<String> createExpenseShare(ExpenseShare share);

  Future<List<ExpenseShare>> getSharesByExpense(String expenseId);

  Future<bool> deleteExpenseShare(String id);
}
