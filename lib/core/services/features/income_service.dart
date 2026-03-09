import 'package:flutter/foundation.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/cloud/feat/income_port_cloud.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncomeService implements IncomeCloudPort {
  final IncomeLocalPort _incomeDao;
  final SupabaseClient _supabaseClient;

  IncomeService(this._incomeDao, this._supabaseClient);

  @override
  Future<List<Income>> getAllIncomes() async {
    return await _incomeDao.getAllIncomes();
  }

  @override
  Future<String> createIncome(NewIncomeDto dto) async {
    final id = await _incomeDao.createIncome(dto);

    try {
      final now = DateTime.now().toIso8601String();
      await _supabaseClient.from('income').insert({
        'id': id,
        'couple_id': dto.coupleId,
        'name': dto.name,
        'transaction_date': now,
        'description': dto.description,
        'amount': (dto.amount * 100).round(),
        'category_id': dto.categoryId,
        'is_recurring': dto.isRecurring,
        'is_received': dto.isReceived,
        'created_at': now,
        'user_recipient_id': dto.userId,
      });
    } catch (e) {
      debugPrint('IncomeService: no se pudo sincronizar con Supabase: $e');
    }

    return id;
  }
}
