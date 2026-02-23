import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'category_service_test.mocks.dart';

@GenerateMocks([CategoryPort, SupabaseClient])
void main() {
  late CategoryService categoryService;
  late MockCategoryPort mockCategoryDao;
  late MockSupabaseClient mockSupabaseClient;

  final testCategory = Category(
    id: 'cat-uuid-1',
    coupleId: 'couple-1',
    name: 'Salario',
    createdAt: DateTime(2024, 1, 1),
    categoryHost: CategoryHost.income,
    syncStatus: SyncStatus.pending,
  );

  setUp(() {
    mockCategoryDao = MockCategoryPort();
    mockSupabaseClient = MockSupabaseClient();
    categoryService = CategoryService(mockCategoryDao, mockSupabaseClient);
  });

  group('CategoryService - getAllCategories', () {
    test('retorna lista de categorías desde el DAO local', () async {
      when(mockCategoryDao.getAllCategories())
          .thenAnswer((_) async => [testCategory]);

      final result = await categoryService.getAllCategories();

      expect(result, hasLength(1));
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
      when(mockCategoryDao.getAllCategories())
          .thenThrow(Exception('DB error'));

      expect(
        () => categoryService.getAllCategories(),
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
      when(mockCategoryDao.createCategory(any))
          .thenAnswer((_) async => generatedId);
      // Supabase falla en silencio (offline-first)
      when(mockSupabaseClient.from(any)).thenThrow(Exception('offline'));

      final result = await categoryService.createCategory(newCategoryDto);

      expect(result, generatedId);
      verify(mockCategoryDao.createCategory(any)).called(1);
    });

    test('retorna ID aunque falle la sincronización con Supabase', () async {
      const generatedId = 'new-uuid-456';
      when(mockCategoryDao.createCategory(any))
          .thenAnswer((_) async => generatedId);
      when(mockSupabaseClient.from(any)).thenThrow(Exception('Network error'));

      final result = await categoryService.createCategory(newCategoryDto);

      expect(result, generatedId);
      verify(mockCategoryDao.createCategory(any)).called(1);
    });

    test('lanza excepción si el DAO falla', () async {
      when(mockCategoryDao.createCategory(any))
          .thenThrow(Exception('SQLite error'));

      expect(
        () => categoryService.createCategory(newCategoryDto),
        throwsException,
      );
    });
  });
}
