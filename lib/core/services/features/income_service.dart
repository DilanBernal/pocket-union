import 'package:flutter/foundation.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/feat/income_port.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncomeService implements IncomePort {
  final IncomePort _incomeDao;
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
      await _supabaseClient.from('income').insert({
        'id': id,
        'couple_id': dto.coupleId,
        'amount': (dto.amount * 100).round(),
        'description': dto.description,
        'category_id': dto.categoryId,
        'transaction_date': DateTime.now().toIso8601String(),
        'is_recurring': dto.isRecurring,
        'is_received': dto.isReceived,
        'created_at': DateTime.now().toIso8601String(),
        'name': dto.name,
        'user_recipient_id': dto.userId,
      });
    } catch (e) {
      debugPrint('IncomeService: no se pudo sincronizar con Supabase: $e');
    }

    return id;
  }
}
