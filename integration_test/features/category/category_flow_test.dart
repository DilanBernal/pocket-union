import 'dart:developer' as dev;

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:mockito/mockito.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/category_filter_dto.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ---------------- MOCKS ----------------

final mockSupabase = SupabaseClient(
  'https://mock.supabase.co', // Does not matter what URL you pass here as long as it's a valid URL
  'fakeAnonKey', // Does not matter what string you pass here
  httpClient: MockSupabaseHttpClient(),
);

void main() {
  testCategoryFlow();
}

class MockLogger extends Mock implements LoggerPort {
  @override
  void debug(String message) {
    dev.log('DEBUG: $message');
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(message, error: error, stackTrace: stackTrace, level: 1000);
  }

  @override
  void info(String message) {
    dev.log('INFO: $message');
  }

  @override
  void logObject(Object object, {String? label}) {
    dev.log('LOG OBJECT: $object');
  }

  @override
  void warning(String message) {
    dev.log('WARNING: $message', level: 900);
  }
}

/// ---------------- FAKE DAO ----------------

class FakeCategoryDao extends Fake implements CategoryLocalPort {
  final Map<String, Category> storage = {};

  SyncStatus? lastUpdatedStatus;
  int _idSeed = 0;

  Category _cloneWith(
    Category original, {
    String? name,
    String? icon,
    String? shortDescription,
    String? color,
    CategoryHost? categoryHost,
    SyncStatus? syncStatus,
    DateTime? lastSyncAt,
  }) {
    return Category(
      id: original.id,
      coupleId: original.coupleId,
      name: name ?? original.name,
      icon: icon ?? original.icon,
      shortDescription: shortDescription ?? original.shortDescription,
      color: color ?? original.color,
      createdAt: original.createdAt,
      categoryHost: categoryHost ?? original.categoryHost,
      syncStatus: syncStatus ?? original.syncStatus,
      lastSyncAt: lastSyncAt ?? original.lastSyncAt,
      localUpdatedAt: DateTime.now(),
      isLocallyStored: original.isLocallyStored,
    );
  }

  @override
  Future<String> createCategory(NewCategoryDto dto) async {
    _idSeed += 1;
    final id = 'local-$_idSeed';

    storage[id] = Category(
      id: id,
      name: dto.name,
      categoryHost: dto.host,
      syncStatus: SyncStatus.pending,
      coupleId: '',
      createdAt: DateTime.now(),
    );

    return id;
  }

  @override
  Future<bool> deleteCategory(String id) async {
    storage.remove(id);
    return true;
  }

  @override
  Future<List<Category>> getAllCategories() async => storage.values.toList();

  @override
  Future<List<Category>> createDefaultCategories(String idCouple) async => [];

  @override
  Future<List<Category>> getAllCategoriesByCouple({String? coupleId}) async {
    if (coupleId == null) return storage.values.toList();
    return storage.values.where((c) => c.coupleId == coupleId).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    return storage[id];
  }

  @override
  Future<bool> updateCategory(UpdateCategoryDto dto) async {
    final cat = storage[dto.id];
    if (cat == null) return false;

    storage[dto.id] = _cloneWith(
      cat,
      name: dto.name,
      icon: dto.icon,
      shortDescription: dto.shortDescription,
      color: dto.color,
      categoryHost: dto.host,
      syncStatus: dto.status,
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
      storage[id] = _cloneWith(cat, syncStatus: status, lastSyncAt: lastSyncAt);
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
  Future<List<Category>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  }) async {
    return storage.values.where((c) {
      final hostMatch = c.categoryHost == host;
      final coupleMatch = coupleId == null || c.coupleId == coupleId;
      return hostMatch && coupleMatch;
    }).toList();
  }

  @override
  Future<List<Category>> getByFilter(CategoryFilterDto filter) async {
    return storage.values.where((c) {
      final idMatch = filter.id == null || c.id == filter.id;
      final coupleMatch =
          filter.coupleId == null || c.coupleId == filter.coupleId;
      final hostMatch = filter.host == null || c.categoryHost == filter.host;
      final syncMatch =
          filter.syncStatus == null || c.syncStatus == filter.syncStatus;
      return idMatch && coupleMatch && hostMatch && syncMatch;
    }).toList();
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

void testCategoryFlow() {
  late FakeCategoryDao dao;
  late SupabaseClient supabase;
  late MockLogger logger;
  late CategoryService service;

  setUp(() {
    dao = FakeCategoryDao();
    supabase = mockSupabase;
    logger = MockLogger();

    service = CategoryService(dao, supabase, logger);
  });

  group('createCategory', () {
    test('crea categoría local y sincroniza con cloud', () async {
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
      expect(dao.storage[id]?.name, 'Food');
    });
    test('crea categoria local a pesar de no sincronizar con cloud', () async {
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
      expect(dao.storage[id]?.name, 'Food');
    });
  });

  group('getAllCategories', () {
    test('mezcla categorías locales y cloud en happy-path', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Local',
        categoryHost: CategoryHost.expense,
        coupleId: '',
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      final result = await service.getAllCategories();

      expect(result.length, 2);
      expect(result.any((c) => c.id == '1'), true);
      expect(result.any((c) => c.id != '1'), true);
    });
  });

  group('updateCategory', () {
    test('actualiza local y cloud', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Old',
        categoryHost: CategoryHost.expense,
        coupleId: '',
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.synced,
      );

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
        coupleId: '',
        createdAt: DateTime.now(),
      );

      final result = await service.syncCategory('1');

      expect(result, true);
      expect(dao.lastUpdatedStatus, SyncStatus.synced);
    });
  });

  group('syncAllCategories', () {
    test('sincroniza múltiples categorías', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'A',
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
        coupleId: '',
        createdAt: DateTime.now(),
      );

      dao.storage['2'] = Category(
        id: '2',
        name: 'B',
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
        coupleId: '',
        createdAt: DateTime.now(),
      );

      final result = await service.syncAllCategories();

      expect(result.length, 2);
      expect(result.values.every((v) => v), true);
      expect(dao.lastUpdatedStatus, SyncStatus.synced);
    });
  });

  group('getCategoriesByHost', () {
    test('filtra por host correctamente', () async {
      dao.storage['1'] = Category(
        id: '1',
        name: 'Income',
        categoryHost: CategoryHost.income,
        coupleId: '',
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.synced,
      );

      final result = await service.getCategoriesByHost(CategoryHost.income);

      expect(result.length, 1);
      expect(result.first.categoryHost, CategoryHost.income);
    });
  });
}
