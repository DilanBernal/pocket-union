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

  IncomeService(this._incomeDao, this._supabaseClient, this._logger);

  @override
  Future<List<Income>> getAllIncomes() async {
    return await _incomeDao.getAllIncomes();
  }

  @override
  Future<String> createIncome(NewIncomeDto dto) async {
    final id = await _incomeDao.createIncome(dto);

    try {
      final now = DateTime.now().toIso8601String();

      // 1. income table
      await _supabaseClient.from('income').insert({
        'id': id,
        'couple_id': dto.coupleId,
        'name': dto.name,
        'transaction_date': now,
        'description': dto.description,
        'amount': (dto.amount * 100).round(),
        'is_received': dto.isReceived,
        'created_at': now,
        'user_recipient_id': dto.userId,
      });

      // 2. income_info table
      await _supabaseClient.from('income_info').insert({
        'income_id': id,
        'is_recurring': dto.isRecurring,
        'is_received': dto.isReceived,
        'received_in': dto.receivedIn,
      });

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
}
