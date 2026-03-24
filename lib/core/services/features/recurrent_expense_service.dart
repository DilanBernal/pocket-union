import 'package:pocket_union/domain/models/recurrent_expense.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_recurrent_expense_port.dart';
import 'package:pocket_union/domain/port/local/recurrent_expense_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_expense_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecurrentExpenseService implements IRecurrentExpensePort {
  final RecurrentExpenseLocalPort _recurrentExpenseDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  RecurrentExpenseService(
    this._recurrentExpenseDao,
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
  Future<List<RecurrentExpense>> getAllRecurrentExpenses() async {
    final local = await _recurrentExpenseDao.getAllRecurrentExpenses();

    try {
      final response = await _supabaseClient
          .from('recurrent_expense')
          .select()
          .order('created_at', ascending: false);

      final cloud = (response as List)
          .map(
            (item) => RecurrentExpense.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      if (local.isEmpty && cloud.isNotEmpty) {
        return cloud;
      }
    } catch (e) {
      _logger.error(
        'RecurrentExpenseService: no se pudo consultar recurrent_expense en Supabase',
        error: e,
      );
    }

    return local;
  }

  @override
  Future<String> createRecurrentExpense(NewRecurrentExpenseDto dto) async {
    final id = await _recurrentExpenseDao.createRecurrentExpense(dto);

    try {
      await _supabaseClient.from('recurrent_expense').insert({
        'id': id,
        'name': dto.name,
        'couple_id': dto.coupleId,
        'created_by': dto.createdBy,
        'amount': (dto.amount * 100).round(),
        'recurrent_info': _toDbRecurrentInfo(dto.recurrentInfo),
      });
    } catch (e) {
      _logger.error(
        'RecurrentExpenseService: no se pudo sincronizar con Supabase',
        error: e,
      );
    }

    return id;
  }
}
