import 'package:pocket_union/domain/models/expense_share.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_expense_share_port.dart';
import 'package:pocket_union/domain/port/local/expense_share_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/expense_share_filter_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseShareService implements IExpenseSharePort {
  final ExpenseShareLocalPort _expenseShareDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  ExpenseShareService(
    this._expenseShareDao,
    this._supabaseClient,
    this._logger,
  );

  @override
  Future<List<ExpenseShare>> getSharesByExpense(String expenseId) async {
    return await _expenseShareDao.getByFilter(
      ExpenseShareFilterDto(expenseId: expenseId),
    );
  }

  @override
  Future<String> createExpenseShare(ExpenseShare share) async {
    final id = await _expenseShareDao.createExpenseShare(share);

    try {
      await _supabaseClient.from('expense_share').insert(share.toJson());
    } catch (e) {
      _logger.error(
        'ExpenseShareService: no se pudo sincronizar con Supabase',
        error: e,
      );
    }

    return id;
  }

  @override
  Future<bool> deleteExpenseShare(String id) async {
    final deleted = await _expenseShareDao.deleteExpenseShare(id);

    try {
      await _supabaseClient.from('expense_share').delete().eq('id', id);
    } catch (e) {
      _logger.error(
        'ExpenseShareService: no se pudo eliminar en Supabase',
        error: e,
      );
    }

    return deleted;
  }
}
