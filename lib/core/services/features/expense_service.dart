import 'dart:async';

import 'package:pocket_union/core/services/util/sync_utils.dart';
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
  Future<void>? _backgroundMissingSync;

  ExpenseService(this._expenseDao, this._supabaseClient, this._logger);

  @override
  Future<List<Expense>> getAllExpenses() async {
    var expensesInLocal = await _expenseDao.getAllExpenses();

    try {
      var response = await _supabaseClient
          .from('expense')
          .select('''
            id,
            couple_id,
            created_by,
            name,
            transaction_date,
            description,
            amount,
            created_at,
            expense_info (
              is_fixed,
              is_planed,
              importance_level
            ),
            expense_category (
              category_id,
              expense_id
            )
          ''')
          .eq('couple_id', expensesInLocal.first.coupleId);

      final expensesInCloud = (response as List).map((item) {
        final rawInfo = item['expense_info'];
        final Map<String, dynamic> info = rawInfo is List
        ? (rawInfo.isNotEmpty
          ? Map<String, dynamic>.from(rawInfo.first)
          : <String, dynamic>{})
        : (rawInfo is Map
          ? Map<String, dynamic>.from(rawInfo)
          : <String, dynamic>{});

        return Expense(
          id: item['id'],
          coupleId: item['couple_id'],
          createdBy: item['created_by'],
          name: item['name'],
          transactionDate: DateTime.parse(item['transaction_date']),
          description: item['description'],
          amount: item['amount'] / 100,
          createdAt: DateTime.parse(item['created_at']),
          isFixed: info['is_fixed'] ?? false,
          isPlaned: info['is_planed'] ?? false,
          importanceLevel: info['importance_level'] ?? 0,
          // categories: categories,
        );
      }).toList();

      var missingLocally = SyncUtils.findMissingInLocal(
        localItems: expensesInLocal,
        cloudItems: expensesInCloud,
        getId: (e) => e.id,
      );

      if (missingLocally.isNotEmpty && _backgroundMissingSync == null) {
        _backgroundMissingSync = _saveMissingExpensesLocally(missingLocally)
            .then((_) {
              _logger.info(
                'ExpenseService.getAllExpenses: ${missingLocally.length} gastos guardados localmente desde Supabase',
              );
            })
            .catchError((e) {
              _logger.error(
                'ExpenseService.getAllExpenses: error al guardar gastos de Supabase en local: $e',
              );
            })
            .whenComplete(() {
              _backgroundMissingSync = null;
            });

        unawaited(_backgroundMissingSync);
      }

      expensesInLocal.addAll(missingLocally);
    } catch (e) {
      _logger.error(
        'ExpenseService: no se pudo cargar desde Supabase',
        error: e,
      );
    }
    return expensesInLocal;
  }

  Future<void> _saveMissingExpensesLocally(List<Expense> expenses) async {
    for (final expense in expenses) {
      await _expenseDao.upsertFromCloud(expense);
    }
  }

  @override
  Future<String> createExpense(NewExpenseDto dto) async {
    final id = await _expenseDao.createExpense(dto);

    try {
      final now = DateTime.now().toIso8601String();
      final transactionDate = (dto.transactionDate ?? DateTime.now())
          .toIso8601String();

      // 1. expense table
      await _supabaseClient.from('expense').insert({
        'id': id,
        'couple_id': dto.coupleId,
        'created_by': dto.createdBy,
        'name': dto.name,
        'transaction_date': transactionDate,
        'description': dto.description,
        'amount': (dto.amount * 100).round(),
        'created_at': now,
      });

      // 2. expense_category table (N:N)
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
      throw Exception('No se pudo guardar el gasto en Supabase: $e');
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
