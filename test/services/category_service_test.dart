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

@GenerateMocks([CategoryPort])
void main() {
  late CategoryService categoryService;
  late MockCategoryPort mockCategoryDao;
  late _FakeSupabaseClient fakeSupabase;

  final tCategory = Category(
    id: 'cat-uuid-1',
    coupleId: 'couple-1',
    name: 'Salario',
    createdAt: DateTime(2024, 1, 1),
    categoryHost: CategoryHost.income,
    syncStatus: SyncStatus.pending,
  );

  setUp(() {
    mockCategoryDao = MockCategoryPort();
    fakeSupabase = _FakeSupabaseClient();
    categoryService = CategoryService(mockCategoryDao, fakeSupabase);
  });

  group('CategoryService - getCategories', () {
    test('retorna lista de categorías del DAO', () async {
      when(mockCategoryDao.getCategories())
          .thenAnswer((_) async => [tCategory]);

      final result = await categoryService.getCategories();

      expect(result, [tCategory]);
      verify(mockCategoryDao.getCategories()).called(1);
    });

    test('retorna lista vacía cuando no hay categorías', () async {
      when(mockCategoryDao.getCategories()).thenAnswer((_) async => []);

      final result = await categoryService.getCategories();

      expect(result, isEmpty);
      verify(mockCategoryDao.getCategories()).called(1);
    });

    test('propaga excepción del DAO', () async {
      when(mockCategoryDao.getCategories())
          .thenThrow(Exception('DB error'));

      expect(
        () => categoryService.getCategories(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('CategoryService - createCategory', () {
    final dto = NewCategoryDto(
      name: 'Salario',
      host: CategoryHost.income,
    );
    const coupleId = 'couple-1';

    test('inserta en DAO y retorna id generado', () async {
      when(mockCategoryDao.createCategory(dto, coupleId))
          .thenAnswer((_) async => 'cat-uuid-1');
      when(mockCategoryDao.getCategories())
          .thenAnswer((_) async => [tCategory]);

      final result = await categoryService.createCategory(dto, coupleId);

      expect(result, 'cat-uuid-1');
      verify(mockCategoryDao.createCategory(dto, coupleId)).called(1);
    });

    test('retorna id aunque Supabase falle (offline-first)', () async {
      // _FakeSupabaseClient siempre lanza excepción, simulando fallo de red
      when(mockCategoryDao.createCategory(dto, coupleId))
          .thenAnswer((_) async => 'cat-uuid-1');
      when(mockCategoryDao.getCategories())
          .thenAnswer((_) async => [tCategory]);

      final result = await categoryService.createCategory(dto, coupleId);

      expect(result, 'cat-uuid-1');
      verify(mockCategoryDao.createCategory(dto, coupleId)).called(1);
    });

    test('propaga excepción si el DAO falla', () async {
      when(mockCategoryDao.createCategory(dto, coupleId))
          .thenThrow(Exception('DB insert error'));

      expect(
        () => categoryService.createCategory(dto, coupleId),
        throwsA(isA<Exception>()),
      );
    });
  });
}

/// Fake SupabaseClient que lanza excepción en cualquier llamada de red,
/// simulando un entorno offline para verificar el comportamiento offline-first.
class _FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) {
    throw Exception('Test: Supabase unavailable');
  }
}

