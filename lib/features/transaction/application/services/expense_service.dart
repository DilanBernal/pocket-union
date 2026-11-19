import 'package:drift/drift.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/core/utils/supabase_client_provider.dart';
import 'package:pocket_union/features/transaction/application/dto/expense_ins_dto.dart';
import 'package:pocket_union/features/transaction/domain/ports/expense_port.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'expense_service.g.dart';

@Riverpod(keepAlive: true)
Future<ExpensePort> expenseService(Ref ref) async {
  final logger = ref.watch(loggerProvider);
  final supabaseClient = await ref.read(supabaseClientProvider.future);
  final db = await ref.read(appDatabaseProvider.future);
  final sharedPrefs = await ref.read(sharedPreferencesWithCacheProvider.future);

  return ExpenseService(
    logger: logger,
    supabaseClient: supabaseClient,
    appDatabase: db,
    sharedPreferences: sharedPrefs,
  );
}

class ExpenseService extends ExpensePort {
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;
  final AppDatabase _db;
  final SharedPreferencesWithCache _prefs;
  final Uuid _uuid = const Uuid();

  ExpenseService({
    required SupabaseClient supabaseClient,
    required LoggerPort logger,
    required AppDatabase appDatabase,
    required SharedPreferencesWithCache sharedPreferences,
  }) : _supabaseClient = supabaseClient,
       _logger = logger,
       _db = appDatabase,
       _prefs = sharedPreferences;

  @override
  Future<AppResponse<String?>> createExpense(ExpenseInsDto data) async {
    final expenseId = _uuid.v4();
    final userId = _prefs.getString(PreferencesCacheKeys.userId);
    final coupleId = _prefs.getString(PreferencesCacheKeys.coupleId);
    final partnerId = _prefs.getString(PreferencesCacheKeys.coupleProfileId);
    final transactionDate = data.transactionDate ?? DateTime.now();
    final shares = data.shares.isNotEmpty
        ? data.shares
        : partnerId != null
        ? [
            if (userId != null)
              ExpenseShareDto(userId: userId, sharePercentage: 50),
            ExpenseShareDto(userId: partnerId, sharePercentage: 50),
          ]
        : userId != null
        ? [ExpenseShareDto(userId: userId, sharePercentage: 100)]
        : const [];

    try {
      await _db.transaction(() async {
        await _db
            .into(_db.expenseTable)
            .insert(
              ExpenseTableCompanion.insert(
                id: expenseId,
                coupleId: Value(coupleId),
                name: data.name,
                createdBy: Value(userId),
                transactionDate: Value(transactionDate),
                description: Value(data.description),
                amount: data.amount,
                isFixed: Value(data.isFixed),
                importanceLevel: data.importanceLevel,
                isPlaned: Value(data.isPlaned),
                isPaid: Value(data.isPaid),
              ),
            );

        await _db
            .into(_db.expenseInfoTable)
            .insert(
              ExpenseInfoTableCompanion.insert(
                id: expenseId,
                importanceLevel: Value(data.importanceLevel),
                isFixed: Value(data.isFixed),
                isPlaned: Value(data.isPlaned),
              ),
            );

        for (final categoryId in data.categoryIds) {
          await _db
              .into(_db.expenseCategories)
              .insert(
                ExpenseCategoriesCompanion.insert(
                  expenseId: expenseId,
                  categoryId: categoryId,
                ),
              );
        }

        for (final share in shares) {
          await _db
              .into(_db.expenseShares)
              .insert(
                ExpenseSharesCompanion.insert(
                  id: _uuid.v4(),
                  expenseId: expenseId,
                  userId: Value(share.userId),
                  sharePercentage: share.sharePercentage,
                ),
              );
        }
      });

      try {
        await _supabaseClient.from('expense').insert({
          'id': expenseId,
          'couple_id': coupleId,
          'amount': data.amount,
          'description': data.description,
          'transaction_date': transactionDate.toIso8601String(),
          'created_by': userId,
          'name': data.name,
          'category_id': data.primaryCategoryId,
          'is_paid': data.isPaid,
        });
        await _supabaseClient.from('expense_info').upsert({
          'id': expenseId,
          'importance_level': data.importanceLevel,
          'is_fixed': data.isFixed,
          'is_planed': data.isPlaned,
        });
        if (data.categoryIds.isNotEmpty) {
          await _supabaseClient
              .from('expense_category')
              .insert(
                data.categoryIds
                    .map(
                      (categoryId) => {
                        'expense_id': expenseId,
                        'category_id': categoryId,
                      },
                    )
                    .toList(),
              );
        }
        if (shares.isNotEmpty) {
          await _supabaseClient
              .from('expense_share')
              .insert(
                shares
                    .map(
                      (share) => {
                        'id': _uuid.v4(),
                        'expense_id': expenseId,
                        'user_id': share.userId,
                        'share_percentage': share.sharePercentage,
                      },
                    )
                    .toList(),
              );
        }
      } catch (error, stackTrace) {
        _logger.error(
          'Error syncing expense creation to Supabase',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return Success(expenseId);
    } catch (error, stackTrace) {
      _logger.error(
        'Error creating expense locally',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
