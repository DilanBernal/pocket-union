import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/dto/new_expense_dto.dart';

abstract class IExpensePort {
  Future<String> createExpense(NewExpenseDto dto);

  Future<List<Expense>> getAllExpenses();

  Future<bool> deleteExpense(String id);
}
