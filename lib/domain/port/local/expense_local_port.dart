import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/dto/filter/expense_filter_dto.dart';
import 'package:pocket_union/dto/new_expense_dto.dart';

abstract class ExpenseLocalPort {
  Future<String> createExpense(NewExpenseDto dto);

  Future<Expense?> getExpenseById(String id);

  Future<List<Expense>> getAllExpenses();

  Future<List<Expense>> getByFilter(ExpenseFilterDto filter);

  Future<bool> updateExpense(Expense expense);

  Future<bool> deleteExpense(String id);

  Future<bool> deleteAllExpenses();
}
