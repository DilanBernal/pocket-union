import 'package:pocket_union/domain/models/expense_share.dart';
import 'package:pocket_union/dto/filter/expense_share_filter_dto.dart';

abstract class ExpenseShareLocalPort {
  Future<String> createExpenseShare(ExpenseShare share);

  Future<ExpenseShare?> getExpenseShareById(String id);

  Future<List<ExpenseShare>> getAllExpenseShares();

  Future<List<ExpenseShare>> getByFilter(ExpenseShareFilterDto filter);

  Future<bool> updateExpenseShare(ExpenseShare share);

  Future<bool> deleteExpenseShare(String id);
}
