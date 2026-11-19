import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/core/utils/supabase_client_provider.dart';
import 'package:pocket_union/features/home/domain/entities/couple_balance_entity.dart';
import 'package:pocket_union/features/home/domain/entities/couple_transaction_entity.dart';
import 'package:pocket_union/features/home/domain/ports/home_port.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'home_service.g.dart';

@Riverpod(keepAlive: true)
Future<HomePort> homeService(Ref ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final logger = ref.watch(loggerProvider);
  final appDatabase = await ref.watch(appDatabaseProvider.future);
  final sharedPreferences = await ref.watch(
    sharedPreferencesWithCacheProvider.future,
  );

  return HomeService(
    supabaseClient: supabaseClient,
    logger: logger,
    appDatabase: appDatabase,
    sharedPreferences: sharedPreferences,
  );
}

class HomeService extends HomePort {
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;
  final AppDatabase _appDatabase;
  final SharedPreferencesWithCache _sharedPreferences;

  HomeService({
    required SupabaseClient supabaseClient,
    required LoggerPort logger,
    required AppDatabase appDatabase,
    required SharedPreferencesWithCache sharedPreferences,
  }) : _supabaseClient = supabaseClient,
       _logger = logger,
       _appDatabase = appDatabase,
       _sharedPreferences = sharedPreferences;

  String? get _coupleId =>
      _sharedPreferences.getString(PreferencesCacheKeys.coupleId);

  @override
  Future<AppResponse<CoupleBalanceEntity>> getCoupleBalance() async {
    final coupleId = _coupleId;
    if (coupleId == null || coupleId.isEmpty) {
      return const Success(CoupleBalanceEntity.zero(coupleId: ''));
    }

    final localBalance = await _getLocalCoupleBalance(coupleId);

    try {
      final row = await _supabaseClient
          .from('couple_balance')
          .select()
          .eq('couple_id', coupleId)
          .maybeSingle();

      if (row == null) {
        return Success(localBalance);
      }
      return Success(CoupleBalanceEntity.fromMap(row));
    } catch (error, stackTrace) {
      _logger.error(
        'Error loading couple balance from Supabase',
        error: error,
        stackTrace: stackTrace,
      );
      return Success(localBalance);
    }
  }

  Future<CoupleBalanceEntity> _getLocalCoupleBalance(String coupleId) async {
    final incomesQuery = _appDatabase.select(_appDatabase.incomeTable)
      ..where((table) => table.coupleId.equals(coupleId));
    final expensesQuery = _appDatabase.select(_appDatabase.expenseTable)
      ..where((table) => table.coupleId.equals(coupleId));

    final incomes = await incomesQuery.get();
    final expenses = await expensesQuery.get();

    final totalIncome = incomes.fold<double>(
      0,
      (total, income) => total + income.amount,
    );
    final totalExpense = expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );

    return CoupleBalanceEntity(
      coupleId: coupleId,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
    );
  }

  @override
  Future<AppResponse<List<CoupleTransactionEntity>>>
  getRecentTransactions() async {
    final coupleId = _coupleId;
    if (coupleId == null || coupleId.isEmpty) {
      return const Success([]);
    }

    final localTransactions = await _getLocalRecentTransactions(coupleId);

    try {
      final rows = await _supabaseClient
          .from('couple_transactions')
          .select()
          .eq('couple_id', coupleId)
          .order('transaction_date', ascending: false)
          .limit(4);

      return Success(
        rows
            .map(
              (row) => CoupleTransactionEntity.fromMap(
                Map<String, dynamic>.from(row),
              ),
            )
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Error loading recent couple transactions from Supabase',
        error: error,
        stackTrace: stackTrace,
      );
      return Success(localTransactions);
    }
  }

  Future<List<CoupleTransactionEntity>> _getLocalRecentTransactions(
    String coupleId,
  ) async {
    final incomesQuery = _appDatabase.select(_appDatabase.incomeTable)
      ..where((table) => table.coupleId.equals(coupleId));
    final expensesQuery = _appDatabase.select(_appDatabase.expenseTable)
      ..where((table) => table.coupleId.equals(coupleId));

    final incomes = await incomesQuery.get();
    final expenses = await expensesQuery.get();

    final transactions = <CoupleTransactionEntity>[
      ...incomes.map(
        (income) => CoupleTransactionEntity(
          id: income.id,
          coupleId: income.coupleId ?? coupleId,
          type: CoupleTransactionType.income,
          amount: income.amount,
          description: income.description,
          transactionDate: income.transactionDate,
          createdBy: income.createdBy,
          name: income.name,
          isPaid: income.isReceived,
        ),
      ),
      ...expenses.map(
        (expense) => CoupleTransactionEntity(
          id: expense.id,
          coupleId: coupleId,
          type: CoupleTransactionType.expense,
          amount: expense.amount,
          description: expense.description,
          transactionDate: expense.transactionDate,
          createdBy: expense.createdBy,
          name: expense.name,
          isPaid: expense.isPaid,
        ),
      ),
    ];

    transactions.sort(
      (first, second) =>
          second.transactionDate.compareTo(first.transactionDate),
    );
    return transactions.take(4).toList(growable: false);
  }
}
