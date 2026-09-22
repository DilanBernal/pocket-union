import 'package:drift/drift.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/current_user_provider.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/core/utils/supabase_client_provider.dart';
import 'package:pocket_union/features/transaction/application/dto/income_ins_dto.dart';
import 'package:pocket_union/features/transaction/domain/ports/income_port.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'income_service.g.dart';

@Riverpod(keepAlive: true)
Future<IncomePort> incomeService(Ref ref) async {
  // final coupleDao = await ref.watch(coupleDaoLocalProvider.future);
  final logger = ref.watch(loggerProvider);
  final supabaseClient = await ref.read(supabaseClientProvider.future);
  final db = await ref.read(appDatabaseProvider.future);
  final sharedPrefs = await ref.read(sharedPreferencesWithCacheProvider.future);
  return IncomeService(
    logger: logger,
    supabaseClient: supabaseClient,
    appDatabase: db,
    sharedPreferences: sharedPrefs,
  );
}

class IncomeService extends IncomePort {
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();
  final SharedPreferencesWithCache _prefs;

  IncomeService({
    required SupabaseClient supabaseClient,
    required LoggerPort logger,
    required AppDatabase appDatabase,
    required SharedPreferencesWithCache sharedPreferences,
  }) : _supabaseClient = supabaseClient,
       _logger = logger,
       _db = appDatabase,
       _prefs = sharedPreferences;

  @override
  Future<void> createIncome(IncomeInsDto data) async {
    try {
      final id = _uuid.v4();
      final response = await _db
          .into(_db.incomeTable)
          .insertReturningOrNull(
            IncomeTableCompanion.insert(
              id: id,
              name: data.name,
              amount: data.amount ?? 0.0,
              description: Value(data.description),
              categoryId: Value(data.primaryCategoryId),
              userRecipientId: data.recipient == 0
                  ? Value(_prefs.getString(PreferencesCacheKeys.userId))
                  : data.recipient == 1
                  ? Value(_prefs.getString(PreferencesCacheKeys.coupleId))
                  : Value.absent(),
              coupleId: Value(_prefs.getString(PreferencesCacheKeys.coupleId)),
            ),
          );

      if (response != null) {
        try {
          await _supabaseClient.from('income').insert({
            'id': response.id,
            'name': response.name,
            'amount': response.amount,
            'description': response.description,
            'category_id': response.categoryId,
            'user_recipient_id': response.userRecipientId,
          });
        } catch (e) {
          _logger.error(
            'Error processing income creation in cloud response: {e}',
            error: e,
          );
        }
      }
      // final response = await _supabaseClient.from('income').select();
      _logger.debug(response.toString());
    } catch (e) {
      _logger.error('Error creating income: $e', error: e);
      rethrow;
    }
  }
}
