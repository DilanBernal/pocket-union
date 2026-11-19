import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/features/transaction/application/dto/expense_ins_dto.dart';
import 'package:pocket_union/features/transaction/application/services/expense_service.dart';

import '../mocks/logger.mock.dart';
import '../mocks/shared_preferences_cache.dart';
import '../mocks/supabaseClient.mock.dart';

void main() {
  late AppDatabase database;
  late MockLogger logger;
  late MockSharedPreferencesWithCache preferences;
  late MockSupabase supabase;
  late ExpenseService service;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    logger = MockLogger();
    preferences = MockSharedPreferencesWithCache();
    supabase = MockSupabase();

    when(
      () => preferences.getString(PreferencesCacheKeys.userId),
    ).thenReturn(null);
    when(
      () => preferences.getString(PreferencesCacheKeys.coupleId),
    ).thenReturn(null);
    when(
      () => preferences.getString(PreferencesCacheKeys.coupleProfileId),
    ).thenReturn(null);
    when(() => supabase.from(any())).thenThrow(Exception('offline'));

    service = ExpenseService(
      logger: logger,
      supabaseClient: supabase,
      appDatabase: database,
      sharedPreferences: preferences,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('persists expense data locally when Supabase is unavailable', () async {
    final response = await service.createExpense(
      ExpenseInsDto(
        name: 'Supermercado',
        amount: 125.50,
        importanceLevel: 2,
        isPaid: true,
      ),
    );

    expect(response, isA<Success<String?>>());
    final expenses = await database.select(database.expenseTable).get();
    final info = await database.select(database.expenseInfoTable).get();

    expect(expenses, hasLength(1));
    expect(expenses.single.name, 'Supermercado');
    expect(expenses.single.amount, 125.50);
    expect(info.single.importanceLevel, 2);
    verify(
      () => logger.error(
        'Error syncing expense creation to Supabase',
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).called(1);
  });
}
