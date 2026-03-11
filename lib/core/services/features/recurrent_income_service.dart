import 'package:pocket_union/domain/models/recurrent_income.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_recurrent_income_port.dart';
import 'package:pocket_union/domain/port/local/recurrent_income_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_income_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecurrentIncomeService implements IRecurrentIncomePort {
  final RecurrentIncomeLocalPort _recurrentIncomeDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  RecurrentIncomeService(
    this._recurrentIncomeDao,
    this._supabaseClient,
    this._logger,
  );

  @override
  Future<List<RecurrentIncome>> getAllRecurrentIncomes() async {
    return await _recurrentIncomeDao.getAllRecurrentIncomes();
  }

  @override
  Future<String> createRecurrentIncome(NewRecurrentIncomeDto dto) async {
    final id = await _recurrentIncomeDao.createRecurrentIncome(dto);

    try {
      await _supabaseClient.from('recurrent_income').insert({
        'id': id,
        'name': dto.name,
        'couple_id': dto.coupleId,
        'amount': (dto.amount * 100).round(),
        'user_recipient_id': dto.userRecipientId,
        'recurrent_info': dto.recurrentInfo,
      });
    } catch (e) {
      _logger.error(
        'RecurrentIncomeService: no se pudo sincronizar con Supabase',
        error: e,
      );
    }

    return id;
  }
}
