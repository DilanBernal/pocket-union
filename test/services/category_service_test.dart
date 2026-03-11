import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'category_service_test.mocks.dart';

@GenerateMocks([CategoryLocalPort, SupabaseClient, LoggerPort])
void main() {
  late CategoryService categoryService;
  late MockCategoryLocalPort mockCategoryDao;
  late MockSupabaseClient mockSupabaseClient;
  late MockLoggerPort mockLogger;

  final incomeCategory = Category(
    id: 'cat-uuid-1',
    coupleId: 'couple-1',
    name: 'Salario',
    createdAt: DateTime(2024, 1, 1),
    categoryHost: CategoryHost.income,
    syncStatus: SyncStatus.pending,
  );

  final expenseCategory = Category(
    id: 'cat-uuid-2',
    coupleId: 'couple-1',
    name: 'Comida',
    createdAt: DateTime(2024, 1, 1),
    categoryHost: CategoryHost.expense,
    syncStatus: SyncStatus.pending,
  );

  setUp(() {
    mockCategoryDao = MockCategoryLocalPort();
    mockSupabaseClient = MockSupabaseClient();
    mockLogger = MockLoggerPort();
    categoryService = CategoryService(
      mockCategoryDao,
      mockSupabaseClient,
      mockLogger,
    );
  });

  group('CategoryService - getAllCategories', () {
    test('retorna lista de categorías desde el DAO local', () async {
      when(
        mockCategoryDao.getAllCategories(),
      ).thenAnswer((_) async => [incomeCategory, expenseCategory]);

      final result = await categoryService.getAllCategories();

      expect(result, hasLength(2));
      expect(result.first.name, 'Salario');
      verify(mockCategoryDao.getAllCategories()).called(1);
    });

    test('retorna lista vacía cuando no hay categorías', () async {
      when(mockCategoryDao.getAllCategories()).thenAnswer((_) async => []);

      final result = await categoryService.getAllCategories();

      expect(result, isEmpty);
      verify(mockCategoryDao.getAllCategories()).called(1);
    });

    test('propaga excepción del DAO', () async {
      when(mockCategoryDao.getAllCategories()).thenThrow(Exception('DB error'));

      expect(() => categoryService.getAllCategories(), throwsException);
    });
  });

  group('CategoryService - getCategoriesByHost', () {
    test('retorna solo categorías del host indicado (INCOME)', () async {
      when(
        mockCategoryDao.getCategoriesByHost(CategoryHost.income),
      ).thenAnswer((_) async => [incomeCategory]);

      final result = await categoryService.getCategoriesByHost(
        CategoryHost.income,
      );

      expect(result, hasLength(1));
      expect(result.first.categoryHost, CategoryHost.income);
      expect(result.first.name, 'Salario');
      verify(
        mockCategoryDao.getCategoriesByHost(CategoryHost.income),
      ).called(1);
    });

    test('retorna solo categorías del host indicado (EXPENSE)', () async {
      when(
        mockCategoryDao.getCategoriesByHost(CategoryHost.expense),
      ).thenAnswer((_) async => [expenseCategory]);

      final result = await categoryService.getCategoriesByHost(
        CategoryHost.expense,
      );

      expect(result, hasLength(1));
      expect(result.first.categoryHost, CategoryHost.expense);
      expect(result.first.name, 'Comida');
      verify(
        mockCategoryDao.getCategoriesByHost(CategoryHost.expense),
      ).called(1);
    });

    test('retorna lista vacía si no hay categorías del host', () async {
      when(
        mockCategoryDao.getCategoriesByHost(CategoryHost.income),
      ).thenAnswer((_) async => []);

      final result = await categoryService.getCategoriesByHost(
        CategoryHost.income,
      );

      expect(result, isEmpty);
      verify(
        mockCategoryDao.getCategoriesByHost(CategoryHost.income),
      ).called(1);
    });

    test('propaga excepción del DAO', () async {
      when(
        mockCategoryDao.getCategoriesByHost(any),
      ).thenThrow(Exception('DB error'));

      expect(
        () => categoryService.getCategoriesByHost(CategoryHost.income),
        throwsException,
      );
    });
  });

  group('CategoryService - createCategory', () {
    final newCategoryDto = NewCategoryDto(
      name: 'Freelance',
      host: CategoryHost.income,
      coupleId: 'couple-1',
    );

    test('inserta en SQLite y devuelve el ID generado', () async {
      const generatedId = 'new-uuid-123';
      when(
        mockCategoryDao.createCategory(any),
      ).thenAnswer((_) async => generatedId);
      // Supabase falla en silencio (offline-first)
      when(mockSupabaseClient.from(any)).thenThrow(Exception('offline'));

      final result = await categoryService.createCategory(newCategoryDto);

      expect(result, generatedId);
      verify(mockCategoryDao.createCategory(any)).called(1);
    });

    test('retorna ID aunque falle la sincronización con Supabase', () async {
      const generatedId = 'new-uuid-456';
      when(
        mockCategoryDao.createCategory(any),
      ).thenAnswer((_) async => generatedId);
      when(mockSupabaseClient.from(any)).thenThrow(Exception('Network error'));

      final result = await categoryService.createCategory(newCategoryDto);

      expect(result, generatedId);
      verify(mockCategoryDao.createCategory(any)).called(1);
    });

    test('lanza excepción si el DAO falla', () async {
      when(
        mockCategoryDao.createCategory(any),
      ).thenThrow(Exception('SQLite error'));

      expect(
        () => categoryService.createCategory(newCategoryDto),
        throwsException,
      );
    });
  });
}
