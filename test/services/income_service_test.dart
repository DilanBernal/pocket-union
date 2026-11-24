import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/transaction/application/services/income_service.dart';

import '../mocks/logger.mock.dart';
import '../mocks/shared_preferences_cache.dart';
import '../mocks/supabaseClient.mock.dart';

void main() {
  late AppDatabase database;
  late MockLogger logger;
  late MockSharedPreferencesWithCache preferences;
  late MockSupabase supabase;
  late IncomeService service;

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
      () => preferences.getString(PreferencesCacheKeys.coupleId),
    ).thenReturn('couple-1');
    when(
      () => preferences.getString(PreferencesCacheKeys.userId),
    ).thenReturn('user-1');
    when(() => supabase.from(any())).thenThrow(Exception('offline'));

    service = IncomeService(
      logger: logger,
      supabaseClient: supabase,
      appDatabase: database,
      sharedPreferences: preferences,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('loads income history first from the local database', () async {
    await database
        .into(database.coupleTable)
        .insert(CoupleTableCompanion.insert(id: 'couple-1'));
    await database
        .into(database.incomeTable)
        .insert(
          IncomeTableCompanion.insert(
            id: 'income-1',
            coupleId: const Value('couple-1'),
            name: 'Salario',
            amount: 1000,
          ),
        );

    final incomes = await service.getLocalIncomes();

    expect(incomes, hasLength(1));
    expect(incomes.single.id, 'income-1');
    expect(incomes.single.name, 'Salario');
  });

  test('marks an income deleted locally when the cloud is offline', () async {
    await database
        .into(database.coupleTable)
        .insert(CoupleTableCompanion.insert(id: 'couple-1'));
    await database
        .into(database.incomeTable)
        .insert(
          IncomeTableCompanion.insert(
            id: 'income-delete',
            coupleId: const Value('couple-1'),
            name: 'Regalo',
            amount: 200,
          ),
        );

    final response = await service.deleteIncome('income-delete');
    final row = await (database.select(
      database.incomeTable,
    )..where((income) => income.id.equals('income-delete'))).getSingle();

    expect(response, isA<Success<bool>>());
    expect(row.isDeleted, isTrue);
    expect(row.syncStatus, SyncStatus.pendingDelete);
  });

  test('keeps local income history when synchronization is offline', () async {
    await database
        .into(database.coupleTable)
        .insert(CoupleTableCompanion.insert(id: 'couple-1'));
    await database
        .into(database.incomeTable)
        .insert(
          IncomeTableCompanion.insert(
            id: 'income-local',
            coupleId: const Value('couple-1'),
            name: 'Freelance',
            amount: 450,
          ),
        );

    await service.synchronizeIncomes();

    final incomes = await service.getLocalIncomes();
    expect(incomes, hasLength(1));
    expect(incomes.single.id, 'income-local');
  });

  test(
    'can persist an income only after creating missing local references',
    () async {
      await database
          .into(database.coupleTable)
          .insert(
            CoupleTableCompanion.insert(
              id: 'couple-remote',
              syncStatus: const Value('synced'),
            ),
          );
      await database
          .into(database.userProfileTable)
          .insert(
            UserProfileTableCompanion.insert(
              id: 'creator-remote',
              syncStatus: const Value('synced'),
            ),
          );
      await database
          .into(database.categoryTable)
          .insert(
            CategoryTableCompanion.insert(
              id: 'category-remote',
              coupleId: 'couple-remote',
              name: 'Ingreso',
              categoryHost: CategoryHost.income,
              syncStatus: const Value(SyncStatus.synced),
            ),
          );

      await database
          .into(database.incomeTable)
          .insert(
            IncomeTableCompanion.insert(
              id: 'income-remote',
              coupleId: const Value('couple-remote'),
              name: 'Ingreso remoto',
              amount: 233,
              createdBy: const Value('creator-remote'),
              categoryId: const Value('category-remote'),
            ),
          );

      final incomes = await database.select(database.incomeTable).get();
      expect(incomes, hasLength(1));
      expect(incomes.single.id, 'income-remote');
    },
  );
}
