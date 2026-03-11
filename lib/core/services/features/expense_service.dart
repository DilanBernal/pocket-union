import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_expense_port.dart';
import 'package:pocket_union/domain/port/local/expense_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_expense_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService implements IExpensePort {
  final ExpenseLocalPort _expenseDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  ExpenseService(this._expenseDao, this._supabaseClient, this._logger);

  @override
  Future<List<Expense>> getAllExpenses() async {
    return await _expenseDao.getAllExpenses();
  }

  @override
  Future<String> createExpense(NewExpenseDto dto) async {
    final id = await _expenseDao.createExpense(dto);

    try {
      final now = DateTime.now().toIso8601String();

      // 1. expense table
      await _supabaseClient.from('expense').insert({
        'id': id,
        'couple_id': dto.coupleId,
        'created_by': dto.createdBy,
        'name': dto.name,
        'transaction_date': now,
        'description': dto.description,
        'amount': (dto.amount * 100).round(),
        'created_at': now,
      });

      // 2. expense_info table
      await _supabaseClient.from('expense_info').insert({
        'id': id,
        'is_fixed': dto.isFixed,
        'is_planed': dto.isPlaned,
        'importance_level': dto.importanceLevel,
      });

      // 3. expense_category table (N:N)
      if (dto.categoryIds.isNotEmpty) {
        await _supabaseClient
            .from('expense_category')
            .insert(
              dto.categoryIds
                  .map((catId) => {'expense_id': id, 'category_id': catId})
                  .toList(),
            );
      }
    } catch (e) {
      _logger.error(
        'ExpenseService: no se pudo sincronizar con Supabase',
        error: e,
      );
    }

    return id;
  }

  @override
  Future<bool> deleteExpense(String id) async {
    final deleted = await _expenseDao.deleteExpense(id);

    try {
      await _supabaseClient.from('expense').delete().eq('id', id);
    } catch (e) {
      _logger.error(
        'ExpenseService: no se pudo eliminar en Supabase',
        error: e,
      );
    }

    return deleted;
  }
}
