import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/services/category_service.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ---------------- MOCKS ----------------

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

class MockLogger extends Mock implements LoggerPort {}

/// ---------------- FAKE DAO ----------------

class FakeCategoryDao extends Fake implements CategoryLocalPort {
  final Map<String, Category> storage = {};

  SyncStatus? lastUpdatedStatus;

  @override
  Future<String> createCategory(NewCategoryDto dto) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    storage[id] = Category(
      id: id,
      name: dto.name,
      categoryHost: dto.host,
      syncStatus: SyncStatus.pending,
    );

    return id;
  }

  @override
  Future<bool> deleteCategory(String id) async {
    storage.remove(id);
    return true;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return storage.values.toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    return storage[id];
  }

  @override
  Future<bool> updateCategory(UpdateCategoryDto dto) async {
    final cat = storage[dto.id];
    if (cat == null) return false;

    storage[dto.id] = cat.copyWith(
      name: dto.name ?? cat.name,
      shortDescription: dto.shortDescription ?? cat.shortDescription,
    );

    return true;
  }

  @override
  Future<void> updateSyncStatus(
    String id,
    SyncStatus status, {
    DateTime? lastSyncAt,
  }) async {
    final cat = storage[id];
    if (cat != null) {
      storage[id] = cat.copyWith(syncStatus: status, lastSyncAt: lastSyncAt);
      lastUpdatedStatus = status;
    }
  }

  @override
  Future<List<Category>> getCategoriesNeedingSync() async {
    return storage.values
        .where(
          (c) =>
              c.syncStatus == SyncStatus.pending ||
              c.syncStatus == SyncStatus.conflict,
        )
        .toList();
  }

  @override
  Future<bool> upsertFromCloud(Category category) async {
    storage[category.id] = category;
    return true;
  }

  @override
  Future<List<Category>> getCategoriesByHost(CategoryHost host) async {
    return storage.values.where((c) => c.categoryHost == host).toList();
  }

  @override
  Future<bool> createCategories(List<NewCategoryDto> categories) async {
    for (var dto in categories) {
      await createCategory(dto);
    }
    return true;
  }

  @override
  Future deleteAllCategories() async {
    storage.clear();
  }

  @override
  Future<bool> updateCategories(List<UpdateCategoryDto> dtos) async {
    for (var dto in dtos) {
      await updateCategory(dto);
    }
    return true;
  }
}

/// ---------------- TESTS ----------------

void main() {
  late FakeCategoryDao dao;
  late MockSupabaseClient supabase;
  late MockLogger logger;
  late CategoryService service;

  late MockPostgrestQueryBuilder query;
  late MockPostgrestFilterBuilder filter;

  setUp(() {
    dao = FakeCategoryDao();
    supabase = MockSupabaseClient();
    logger = MockLogger();

    query = MockPostgrestQueryBuilder();
    filter = MockPostgrestFilterBuilder();

    service = CategoryService(dao, supabase, logger);
  });

  group('createCategory', () {
    test('crea categoría local y sincroniza con cloud', () async {
      when(() => supabase.from('category')).thenReturn(query);
      when(() => query.insert(any())).thenAnswer((_) async => {});

      final dto = NewCategoryDto(
        coupleId: '1',
        name: 'Food',
        icon: '123',
        shortDescription: 'Comida',
        color: '#FF0000',
        host: CategoryHost.expense,
      );

      final id = await service.createCategory(dto);

      expect(id, isNotNull);
      expect(dao.storage.length, 1);
    });
  });

  group('getAllCategories', () {
    test('mezcla categorías locales y cloud', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Local',
        categoryHost: CategoryHost.expense,
      );

      when(() => supabase.from('category')).thenReturn(query);
      when(() => query.select()).thenAnswer(
        (_) async => [
          {'id': '2', 'name': 'Cloud', 'category_host': 'expense'},
        ],
      );

      final result = await service.getAllCategories();

      expect(result.length, 2);
    });
  });

  group('updateCategory', () {
    test('actualiza local y cloud', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Old',
        categoryHost: CategoryHost.expense,
      );

      when(() => supabase.from('category')).thenReturn(query);
      when(() => query.update(any())).thenReturn(filter);
      when(() => filter.eq(any(), any())).thenAnswer((_) async => {});

      final dto = UpdateCategoryDto(id: '1', name: 'New');

      final result = await service.updateCategory(dto);

      expect(result, true);
      expect(dao.storage['1']!.name, 'New');
    });
  });

  group('syncCategory', () {
    test('sincroniza categoría pending', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Sync',
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      );

      when(() => supabase.from('category')).thenReturn(query);
      when(() => query.upsert(any())).thenAnswer((_) async => {});

      final result = await service.syncCategory('1');

      expect(result, true);
      expect(dao.lastUpdatedStatus, SyncStatus.synced);
    });

    test('marca conflicto si falla Supabase', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Sync',
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      );

      when(() => supabase.from('category')).thenReturn(query);
      when(() => query.upsert(any())).thenThrow(Exception());

      final result = await service.syncCategory('1');

      expect(result, false);
      expect(dao.lastUpdatedStatus, SyncStatus.conflict);
    });
  });

  group('syncAllCategories', () {
    test('sincroniza múltiples categorías', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'A',
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      );

      dao.storage['2'] = Category(
        id: '2',
        name: 'B',
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      );

      when(() => supabase.from('category')).thenReturn(query);
      when(() => query.upsert(any())).thenAnswer((_) async => {});

      final result = await service.syncAllCategories();

      expect(result.length, 2);
      expect(result.values.every((v) => v), true);
    });
  });

  group('getCategoriesByHost', () {
    test('filtra por host correctamente', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Income',
        categoryHost: CategoryHost.income,
      );

      when(() => supabase.from('category')).thenReturn(query);
      when(() => query.select()).thenReturn(filter);
      when(() => filter.eq(any(), any())).thenAnswer((_) async => []);

      final result = await service.getCategoriesByHost(CategoryHost.income);

      expect(result.length, 1);
      expect(result.first.categoryHost, CategoryHost.income);
    });
  });
}
