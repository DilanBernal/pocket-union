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

  List<int>? _toDbRecurrentInfo(String? recurrentInfo) {
    if (recurrentInfo == null || recurrentInfo.trim().isEmpty) return null;

    final tokens = recurrentInfo.trim().split(RegExp(r'\s+'));
    return tokens.map((token) {
      final parsed = int.tryParse(token);
      return parsed ?? -1;
    }).toList();
  }

  @override
  Future<List<RecurrentIncome>> getAllRecurrentIncomes() async {
    final local = await _recurrentIncomeDao.getAllRecurrentIncomes();

    try {
      final response = await _supabaseClient
          .from('recurrent_income')
          .select()
          .order('created_at', ascending: false);

      final cloud = (response as List)
          .map((item) => RecurrentIncome.fromJson(item as Map<String, dynamic>))
          .toList();

      if (local.isEmpty && cloud.isNotEmpty) {
        return cloud;
      }
    } catch (e) {
      _logger.error(
        'RecurrentIncomeService: no se pudo consultar recurrent_income en Supabase',
        error: e,
      );
    }

    return local;
  }

  @override
  Future<String> createRecurrentIncome(NewRecurrentIncomeDto dto) async {
    final id = await _recurrentIncomeDao.createRecurrentIncome(dto);

    try {
      await _supabaseClient.from('recurrent_income').insert({
        'id': id,
        'name': dto.name,
        'couple_id': dto.coupleId,
        'created_by': dto.createdBy,
        'amount': (dto.amount * 100).round(),
        'user_recipient_id': dto.userRecipientId,
        'recurrent_info': _toDbRecurrentInfo(dto.recurrentInfo),
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
