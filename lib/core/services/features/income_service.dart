import 'dart:async';

import 'package:pocket_union/core/services/util/sync_utils.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_income_port.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncomeService implements IIncomePort {
  final IncomeLocalPort _incomeDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;
  Future<void>? _backgroundMissingSync;

  IncomeService(this._incomeDao, this._supabaseClient, this._logger);

  @override
  Future<List<Income>> getAllIncomes() async {
    var incomesInLocal = await _incomeDao.getAllIncomes();

    try {
      final response = await _supabaseClient.from('income').select('''
            id,
            couple_id,
            name,
            transaction_date,
            description,
            amount,
            is_received,
            created_at,
            user_recipient_id,
            income_info (
              is_recurring,
              is_received,
              received_in
            ),
            income_category (
              category_id,
              income_id
            )
          ''');

      final incomesInCloud = (response as List).map((item) {
        final rawInfo = item['income_info'];
        final Map<String, dynamic> info = rawInfo is List
            ? (rawInfo.isNotEmpty
                  ? Map<String, dynamic>.from(rawInfo.first)
                  : <String, dynamic>{})
            : (rawInfo is Map
                  ? Map<String, dynamic>.from(rawInfo)
                  : <String, dynamic>{});

        final rawCategories = item['income_category'];
        final categoryIds = rawCategories is List
            ? rawCategories
                  .map((entry) => entry['category_id'])
                  .whereType<String>()
                  .toList()
            : <String>[];

        return Income(
          id: item['id'],
          coupleId: item['couple_id'],
          name: item['name'],
          transactionDate: DateTime.parse(item['transaction_date']),
          description: item['description'],
          amount: (item['amount'] as num).toDouble() / 100,
          categoryIds: categoryIds,
          isRecurring: info['is_recurring'] ?? false,
          isReceived: item['is_received'] ?? true,
          receivedIn: info['received_in'] as Map<String, dynamic>?,
          createdAt: DateTime.parse(item['created_at']),
          userRecipientId: item['user_recipient_id'],
        );
      }).toList();

      final missingLocally = SyncUtils.findMissingInLocal(
        localItems: incomesInLocal,
        cloudItems: incomesInCloud,
        getId: (e) => e.id,
      );

      if (missingLocally.isNotEmpty && _backgroundMissingSync == null) {
        _backgroundMissingSync = _saveMissingIncomesLocally(missingLocally)
            .then((_) {
              _logger.info(
                'IncomeService.getAllIncomes: ${missingLocally.length} ingresos guardados localmente desde Supabase',
              );
            })
            .catchError((e) {
              _logger.error(
                'IncomeService.getAllIncomes: error al guardar ingresos de Supabase en local: $e',
              );
            })
            .whenComplete(() {
              _backgroundMissingSync = null;
            });

        unawaited(_backgroundMissingSync);
      }

      incomesInLocal.addAll(missingLocally);
    } catch (e) {
      _logger.error(
        'IncomeService: no se pudo cargar desde Supabase',
        error: e,
      );
    }

    return incomesInLocal;
  }

  Future<void> _saveMissingIncomesLocally(List<Income> incomes) async {
    for (final income in incomes) {
      await _incomeDao.upsertFromCloud(income);
    }
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    return _incomeDao.getIncomeById(id);
  }

  @override
  Future<String> createIncome(NewIncomeDto dto) async {
    final id = await _incomeDao.createIncome(dto);

    try {
      final now = DateTime.now().toIso8601String();
      final transactionDate = (dto.transactionDate ?? DateTime.now())
          .toIso8601String();

      // 1. income table
      await _supabaseClient.from('income').insert({
        'id': id,
        'couple_id': dto.coupleId,
        'name': dto.name,
        'transaction_date': transactionDate,
        'description': dto.description,
        'amount': (dto.amount * 100).round(),
        'is_received': dto.isReceived,
        'created_at': now,
        'user_recipient_id': dto.userId,
      });

      // 2. income_info table
      await _supabaseClient.from('income_info').upsert({
        'income_id': id,
        'is_recurring': dto.isRecurring,
        'is_received': dto.isReceived,
        'received_in': dto.receivedIn,
      }, onConflict: 'income_id');

      // 3. income_category table (N:N)
      if (dto.categoryIds.isNotEmpty) {
        await _supabaseClient
            .from('income_category')
            .insert(
              dto.categoryIds
                  .map((catId) => {'income_id': id, 'category_id': catId})
                  .toList(),
            );
      }
    } catch (e) {
      _logger.error(
        'IncomeService: no se pudo sincronizar con Supabase',
        error: e,
      );
    }

    return id;
  }

  @override
  Future<bool> updateIncome(String id, NewIncomeDto dto) async {
    final current = await _incomeDao.getIncomeById(id);
    if (current == null) return false;

    final updatedIncome = Income(
      id: current.id,
      coupleId: current.coupleId,
      name: dto.name,
      transactionDate: dto.transactionDate ?? current.transactionDate,
      description: dto.description,
      amount: dto.amount,
      categoryIds: dto.categoryIds,
      isRecurring: dto.isRecurring,
      isReceived: dto.isReceived,
      receivedIn: dto.receivedIn as Map<String, dynamic>?,
      createdAt: current.createdAt,
      userRecipientId: dto.userId,
      syncStatus: current.syncStatus,
      isDeleted: current.isDeleted,
    );

    final updated = await _incomeDao.updateIncome(updatedIncome);
    if (!updated) return false;

    try {
      await _supabaseClient
          .from('income')
          .update({
            'name': dto.name,
            'transaction_date': (dto.transactionDate ?? current.transactionDate)
                .toIso8601String(),
            'description': dto.description,
            'amount': (dto.amount * 100).round(),
            'is_received': dto.isReceived,
            'user_recipient_id': dto.userId,
          })
          .eq('id', id);

      await _supabaseClient.from('income_info').upsert({
        'income_id': id,
        'is_recurring': dto.isRecurring,
        'is_received': dto.isReceived,
        'received_in': dto.receivedIn,
      }, onConflict: 'income_id');

      await _supabaseClient
          .from('income_category')
          .delete()
          .eq('income_id', id);

      if (dto.categoryIds.isNotEmpty) {
        await _supabaseClient
            .from('income_category')
            .insert(
              dto.categoryIds
                  .map((catId) => {'income_id': id, 'category_id': catId})
                  .toList(),
            );
      }
    } catch (e) {
      _logger.error(
        'IncomeService: no se pudo sincronizar actualización con Supabase',
        error: e,
      );
    }

    return true;
  }

  @override
  Future<bool> deleteIncome(String id) async {
    final deleted = await _incomeDao.deleteIncome(id);
    if (!deleted) return false;

    try {
      await _supabaseClient.from('income').delete().eq('id', id);
    } catch (e) {
      _logger.error('IncomeService: no se pudo eliminar en Supabase', error: e);
    }

    return true;
  }
}
