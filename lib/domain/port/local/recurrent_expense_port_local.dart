import 'package:pocket_union/domain/models/recurrent_expense.dart';
import 'package:pocket_union/dto/new_recurrent_expense_dto.dart';

abstract class RecurrentExpenseLocalPort {
  Future<String> createRecurrentExpense(NewRecurrentExpenseDto dto);
  Future<RecurrentExpense?> getRecurrentExpenseById(String id);
  Future<List<RecurrentExpense>> getAllRecurrentExpenses();
  Future<bool> updateRecurrentExpense(RecurrentExpense recurrentExpense);
  Future<bool> deleteRecurrentExpense(String id);
}
