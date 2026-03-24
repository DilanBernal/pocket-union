import 'package:pocket_union/domain/models/recurrent_expense.dart';
import 'package:pocket_union/dto/new_recurrent_expense_dto.dart';

abstract class IRecurrentExpensePort {
  Future<String> createRecurrentExpense(NewRecurrentExpenseDto dto);
  Future<List<RecurrentExpense>> getAllRecurrentExpenses();
}
