import 'dart:async';

import 'package:drift/drift.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/core/utils/supabase_client_provider.dart';
import 'package:pocket_union/features/transaction/application/dto/expense_ins_dto.dart';
import 'package:pocket_union/features/transaction/domain/entities/expense_entity.dart';
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
  Future<AppResponse<bool>> deleteExpense(String id) async {
    try {
      await (_db.update(
        _db.expenseTable,
      )..where((expense) => expense.id.equals(id))).write(
        ExpenseTableCompanion(
          isDeleted: const Value(true),
          syncStatus: const Value(SyncStatus.pendingDelete),
          localUpdatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      try {
        await _supabaseClient.from('expense').delete().eq('id', id);
        await (_db.update(
          _db.expenseTable,
        )..where((expense) => expense.id.equals(id))).write(
          ExpenseTableCompanion(
            syncStatus: const Value(SyncStatus.synced),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ),
        );
      } catch (error, stackTrace) {
        _logger.error(
          'Error syncing expense deletion to Supabase',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return const Success(true);
    } catch (error, stackTrace) {
      _logger.error(
        'Error deleting expense locally',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<ExpenseEntity>> getLocalExpenses() async {
    final coupleId = _prefs.getString(PreferencesCacheKeys.coupleId);
    if (coupleId == null || coupleId.isEmpty) {
      return const [];
    }

    final query = _db.select(_db.expenseTable)
      ..where(
        (expense) =>
            expense.coupleId.equals(coupleId) & expense.isDeleted.equals(false),
      )
      ..orderBy([
        (expense) => OrderingTerm(
          expression: expense.transactionDate,
          mode: OrderingMode.desc,
        ),
      ]);
    final rows = await query.get();

    final entities = <ExpenseEntity>[];
    for (final row in rows) {
      final categoryQuery = _db.select(_db.expenseCategories)
        ..where(
          (category) =>
              category.expenseId.equals(row.id) &
              category.isDeleted.equals(false),
        );
      final categoryRows = await categoryQuery.get();

      entities.add(
        ExpenseEntity(
          id: row.id,
          coupleId: row.coupleId ?? coupleId,
          createdBy: row.createdBy ?? '',
          name: row.name,
          transactionDate: row.transactionDate,
          description: row.description,
          amount: row.amount,
          categoryIds: categoryRows.map((item) => item.categoryId).toList(),
          isFixed: row.isFixed,
          importanceLevel: row.importanceLevel,
          isPlaned: row.isPlaned,
          createdAt: row.createdAt,
          syncStatus: row.syncStatus,
          lastSyncedAt: row.lastSyncedAt,
          localUpdatedAt: row.localUpdatedAt,
          isPaid: row.isPaid,
        ),
      );
    }
    return entities;
  }

  @override
  Future<void> synchronizeExpenses() async {
    final coupleId = _prefs.getString(PreferencesCacheKeys.coupleId);
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }

    try {
      final localExpenses = await getLocalExpenses();
      final localLatest = localExpenses.isEmpty
          ? null
          : localExpenses.reduce(
              (first, second) =>
                  first.createdAt.isAfter(second.createdAt) ? first : second,
            );

      final latestRemote = await _supabaseClient
          .from('expense')
          .select('id, created_at')
          .eq('couple_id', coupleId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (localLatest != null &&
          latestRemote != null &&
          latestRemote['id']?.toString() == localLatest.id) {
        await _refreshLatestTenExpenses(coupleId);
        return;
      }

      var newExpensesQuery = _supabaseClient
          .from('expense')
          .select()
          .eq('couple_id', coupleId);
      if (localLatest != null) {
        newExpensesQuery = newExpensesQuery.gt(
          'created_at',
          localLatest.createdAt.toUtc().toIso8601String(),
        );
      }
      var orderedNewExpensesQuery = newExpensesQuery.order(
        'created_at',
        ascending: true,
      );
      final newExpenses = localLatest == null
          ? await orderedNewExpensesQuery.limit(100)
          : await orderedNewExpensesQuery;

      final newIds = <String>{};
      for (final remoteExpense in newExpenses) {
        final expense = await _upsertRemoteExpense(
          Map<String, dynamic>.from(remoteExpense),
          coupleId,
        );
        newIds.add(expense.id);
      }

      await _refreshLatestTenExpenses(coupleId, excludedIds: newIds);
    } catch (error, stackTrace) {
      _logger.error(
        'Error synchronizing expense history',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _refreshLatestTenExpenses(
    String coupleId, {
    Set<String> excludedIds = const {},
  }) async {
    final query = _db.select(_db.expenseTable)
      ..where(
        (expense) =>
            expense.coupleId.equals(coupleId) & expense.isDeleted.equals(false),
      )
      ..orderBy([
        (expense) => OrderingTerm(
          expression: expense.createdAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(10);
    final localRows = await query.get();
    final ids = localRows
        .map((expense) => expense.id)
        .where((id) => !excludedIds.contains(id))
        .take(10)
        .toList(growable: false);
    if (ids.isEmpty) {
      return;
    }

    final remoteRows = await _supabaseClient
        .from('expense')
        .select()
        .eq('couple_id', coupleId)
        .inFilter('id', ids);

    for (final remoteExpense in remoteRows) {
      await _upsertRemoteExpense(
        Map<String, dynamic>.from(remoteExpense),
        coupleId,
      );
    }
  }

  Future<ExpenseEntity> _upsertRemoteExpense(
    Map<String, dynamic> row,
    String coupleId,
  ) async {
    final id = row['id'].toString();
    final createdAt =
        DateTime.tryParse(row['created_at']?.toString() ?? '') ??
        DateTime.now().toUtc();
    final transactionDate =
        DateTime.tryParse(row['transaction_date']?.toString() ?? '') ??
        createdAt;
    final categoryId = row['category_id']?.toString();

    await _db
        .into(_db.expenseTable)
        .insertOnConflictUpdate(
          ExpenseTableCompanion(
            id: Value(id),
            coupleId: Value(row['couple_id']?.toString() ?? coupleId),
            name: Value(row['name']?.toString() ?? ''),
            createdBy: Value(row['created_by']?.toString()),
            transactionDate: Value(transactionDate),
            description: Value(row['description']?.toString()),
            amount: Value((row['amount'] as num? ?? 0).toDouble()),
            isFixed: Value(row['is_fixed'] == true),
            importanceLevel: Value(
              (row['importance_level'] as num?)?.toInt() ?? 1,
            ),
            isPlaned: Value(row['is_planed'] == true),
            isPaid: Value(row['is_paid'] != false),
            createdAt: Value(createdAt),
            syncStatus: const Value(SyncStatus.synced),
            localUpdatedAt: Value(DateTime.now().toUtc()),
            lastSyncedAt: Value(DateTime.now().toUtc()),
            isDeleted: const Value(false),
          ),
        );

    final categoryRows = await _supabaseClient
        .from('expense_category')
        .select('category_id')
        .eq('expense_id', id);
    final categoryIds = categoryRows
        .map((item) => item['category_id']?.toString())
        .whereType<String>()
        .toSet();
    if (categoryId != null) {
      categoryIds.add(categoryId);
    }

    await (_db.delete(
      _db.expenseCategories,
    )..where((category) => category.expenseId.equals(id))).go();
    for (final categoryId in categoryIds) {
      await _db
          .into(_db.expenseCategories)
          .insertOnConflictUpdate(
            ExpenseCategoriesCompanion.insert(
              expenseId: id,
              categoryId: categoryId,
              syncStatus: const Value(SyncStatus.synced),
              localUpdatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    }

    final infoRows = await _supabaseClient
        .from('expense_info')
        .select()
        .eq('id', id)
        .limit(1);
    final info = infoRows.isEmpty ? null : infoRows.first;
    final importanceLevel =
        (info?['importance_level'] as num?)?.toInt() ??
        (row['importance_level'] as num?)?.toInt() ??
        1;
    await _db
        .into(_db.expenseInfoTable)
        .insertOnConflictUpdate(
          ExpenseInfoTableCompanion.insert(
            id: id,
            importanceLevel: Value(importanceLevel),
            isFixed: Value(info?['is_fixed'] == true),
            isPlaned: Value(info?['is_planed'] == true),
          ),
        );

    return ExpenseEntity(
      id: id,
      coupleId: coupleId,
      createdBy: row['created_by']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      transactionDate: transactionDate,
      description: row['description']?.toString(),
      amount: (row['amount'] as num? ?? 0).toDouble(),
      categoryIds: categoryIds.toList(growable: false),
      isFixed: info?['is_fixed'] == true,
      importanceLevel: importanceLevel,
      isPlaned: info?['is_planed'] == true,
      createdAt: createdAt,
      syncStatus: SyncStatus.synced,
      lastSyncedAt: DateTime.now().toUtc(),
      localUpdatedAt: DateTime.now().toUtc(),
      isPaid: row['is_paid'] != false,
    );
  }

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
