import 'package:drift/drift.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/core/utils/supabase_client_provider.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/transaction/application/dto/income_ins_dto.dart';
import 'package:pocket_union/features/transaction/domain/entities/income_entity.dart';
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
  Future<List<IncomeEntity>> getLocalIncomes() async {
    final coupleId = _prefs.getString(PreferencesCacheKeys.coupleId);
    if (coupleId == null || coupleId.isEmpty) {
      return const [];
    }

    final query = _db.select(_db.incomeTable)
      ..where(
        (income) =>
            income.coupleId.equals(coupleId) & income.isDeleted.equals(false),
      )
      ..orderBy([
        (income) => OrderingTerm(
          expression: income.transactionDate,
          mode: OrderingMode.desc,
        ),
      ]);
    final rows = await query.get();

    return rows
        .map(
          (row) => IncomeEntity(
            id: row.id,
            coupleId: row.coupleId ?? coupleId,
            amount: row.amount,
            description: row.description,
            transactionDate: row.transactionDate,
            createdAt: row.createdAt,
            name: row.name,
            userRecipientId: row.userRecipientId,
            categoryId: row.categoryId ?? '',
            createdBy: row.createdBy ?? '',
            isReceived: row.isReceived,
            syncStatus: row.syncStatus,
            lastSyncedAt: row.lastSyncedAt,
            localUpdatedAt: row.localUpdatedAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<AppResponse<bool>> deleteIncome(String id) async {
    try {
      await (_db.update(
        _db.incomeTable,
      )..where((income) => income.id.equals(id))).write(
        IncomeTableCompanion(
          isDeleted: const Value(true),
          syncStatus: const Value(SyncStatus.pendingDelete),
          localUpdatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      try {
        await _supabaseClient.from('income').delete().eq('id', id);
        await (_db.update(
          _db.incomeTable,
        )..where((income) => income.id.equals(id))).write(
          IncomeTableCompanion(
            syncStatus: const Value(SyncStatus.synced),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ),
        );
      } catch (error, stackTrace) {
        _logger.error(
          'Error syncing income deletion to Supabase',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return const Success(true);
    } catch (error, stackTrace) {
      _logger.error(
        'Error deleting income locally',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> synchronizeIncomes() async {
    final coupleId = _prefs.getString(PreferencesCacheKeys.coupleId);
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }

    try {
      final localIncomes = await getLocalIncomes();
      final localLatest = localIncomes.isEmpty
          ? null
          : localIncomes.reduce(
              (first, second) =>
                  first.createdAt.isAfter(second.createdAt) ? first : second,
            );

      final latestRemote = await _supabaseClient
          .from('income')
          .select('id, created_at')
          .eq('couple_id', coupleId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (localLatest != null &&
          latestRemote != null &&
          latestRemote['id']?.toString() == localLatest.id) {
        await _refreshLatestTenIncomes(coupleId);
        return;
      }

      var query = _supabaseClient
          .from('income')
          .select()
          .eq('couple_id', coupleId);
      if (localLatest != null) {
        query = query.gt(
          'created_at',
          localLatest.createdAt.toUtc().toIso8601String(),
        );
      }
      final remoteRows = localLatest == null
          ? await query.order('created_at', ascending: true).limit(100)
          : await query.order('created_at', ascending: true);
      await _upsertRemoteIncomes(coupleId, remoteRows);
    } catch (error, stackTrace) {
      _logger.error(
        'Error synchronizing income history',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _ensureRemoteReferences({
    required String coupleId,
    String? createdById,
    String? recipientId,
    String? categoryId,
  }) async {
    final localCouple = await (_db.select(
      _db.coupleTable,
    )..where((couple) => couple.id.equals(coupleId))).getSingleOrNull();
    if (localCouple == null) {
      await _db
          .into(_db.coupleTable)
          .insertOnConflictUpdate(
            CoupleTableCompanion.insert(
              id: coupleId,
              syncStatus: const Value('synced'),
              localUpdatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    }

    for (final profileId in {createdById, recipientId}.whereType<String>()) {
      final localProfile = await (_db.select(
        _db.userProfileTable,
      )..where((profile) => profile.id.equals(profileId))).getSingleOrNull();
      if (localProfile == null) {
        await _db
            .into(_db.userProfileTable)
            .insertOnConflictUpdate(
              UserProfileTableCompanion.insert(
                id: profileId,
                inCloud: const Value(true),
                syncStatus: const Value('synced'),
                localUpdatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    }

    if (categoryId != null) {
      final localCategory = await (_db.select(
        _db.categoryTable,
      )..where((category) => category.id.equals(categoryId))).getSingleOrNull();
      if (localCategory == null) {
        await _db
            .into(_db.categoryTable)
            .insertOnConflictUpdate(
              CategoryTableCompanion.insert(
                id: categoryId,
                coupleId: coupleId,
                name: 'Categoría',
                categoryHost: CategoryHost.income,
                syncStatus: const Value(SyncStatus.synced),
                localUpdatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    }
  }

  Future<void> _refreshLatestTenIncomes(String coupleId) async {
    final query = _db.select(_db.incomeTable)
      ..where(
        (income) =>
            income.coupleId.equals(coupleId) & income.isDeleted.equals(false),
      )
      ..orderBy([
        (income) =>
            OrderingTerm(expression: income.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(10);
    final localRows = await query.get();
    if (localRows.isEmpty) return;

    final remoteRows = await _supabaseClient
        .from('income')
        .select()
        .eq('couple_id', coupleId)
        .inFilter('id', localRows.map((row) => row.id).toList());
    await _upsertRemoteIncomes(coupleId, remoteRows);
  }

  Future<void> _upsertRemoteIncomes(
    String coupleId,
    List<Map<String, dynamic>> rows,
  ) async {
    for (final row in rows) {
      final id = row['id'].toString();
      final remoteCoupleId = row['couple_id']?.toString();
      final remoteCreatedBy = row['created_by']?.toString();
      final remoteRecipientId = row['user_recipient_id']?.toString();
      final remoteCategoryId = row['category_id']?.toString();

      await _ensureRemoteReferences(
        coupleId: remoteCoupleId ?? coupleId,
        createdById: remoteCreatedBy,
        recipientId: remoteRecipientId,
        categoryId: remoteCategoryId,
      );

      final createdAt =
          DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now().toUtc();
      final transactionDate =
          DateTime.tryParse(row['transaction_date']?.toString() ?? '') ??
          createdAt;
      await _db
          .into(_db.incomeTable)
          .insertOnConflictUpdate(
            IncomeTableCompanion(
              id: Value(id),
              coupleId: Value(remoteCoupleId ?? coupleId),
              name: Value(row['name']?.toString() ?? ''),
              createdBy: Value(remoteCreatedBy),
              userRecipientId: Value(remoteRecipientId),
              transactionDate: Value(transactionDate),
              categoryId: Value(remoteCategoryId),
              description: Value(row['description']?.toString()),
              amount: Value((row['amount'] as num? ?? 0).toDouble()),
              isReceived: Value(row['is_received'] != false),
              createdAt: Value(createdAt),
              syncStatus: const Value(SyncStatus.synced),
              localUpdatedAt: Value(DateTime.now().toUtc()),
              lastSyncedAt: Value(DateTime.now().toUtc()),
              isDeleted: const Value(false),
            ),
          );
    }
  }

  @override
  Future<AppResponse<String?>> createIncome(IncomeInsDto data) async {
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
              createdBy: Value(_prefs.getString(PreferencesCacheKeys.userId)),
              userRecipientId: data.recipient == 0
                  ? Value(_prefs.getString(PreferencesCacheKeys.userId))
                  : data.recipient == 1
                  ? Value(
                      _prefs.getString(PreferencesCacheKeys.coupleProfileId),
                    )
                  : Value.absent(),
              coupleId: Value(_prefs.getString(PreferencesCacheKeys.coupleId)),
              isReceived: Value(data.isReceived ?? true),
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
            'couple_id': _prefs.getString(PreferencesCacheKeys.coupleId),
            'created_by': _prefs.getString(PreferencesCacheKeys.userId),
            'is_received': response.isReceived,
          });
          final responseCategory = await _supabaseClient
              .from('income_category')
              .insert(
                data.categoryIds?.map((categoryId) {
                      return {
                        'income_id': response.id,
                        'category_id': categoryId,
                      };
                    }).toList() ??
                    [],
              );
          _logger.debug(responseCategory.toString());
        } catch (e) {
          _logger.error(
            'Error processing income creation in cloud response: {e}',
            error: e,
          );
        }
      }
      // final response = await _supabaseClient.from('income').select();
      _logger.debug(response.toString());
      return Success(id);
    } catch (e) {
      _logger.error('Error creating income: $e', error: e);
      rethrow;
    }
  }
}
