import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/utils/categories_list_provider.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/features/reference/application/services/category_service.dart';
import 'package:pocket_union/features/reference/category/dtos/category_ins_dto.dart';
import 'package:pocket_union/features/reference/category/dtos/category_upd_dto.dart';
import 'package:pocket_union/features/reference/category/presentation/controller/category_command_controller.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';

import '../mocks/category_service.mock.dart';
import '../mocks/logger.mock.dart';

typedef FormBuilderFieldStateAny =
    FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>;

class FakeFormBuilderState extends Fake implements FormBuilderState {
  FakeFormBuilderState({required this.valid, required this.fields});

  final bool valid;
  @override
  final Map<String, FormBuilderFieldStateAny> fields;

  @override
  bool saveAndValidate({
    bool focusOnInvalid = true,
    bool autoScrollWhenFocusOnInvalid = false,
  }) =>
      valid;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'FakeFormBuilderState';
}

class FakeFormFieldState extends Fake implements FormBuilderFieldStateAny {
  FakeFormFieldState(this.value);

  @override
  final dynamic value;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'FakeFormFieldState';
}

void main() {
  late ProviderContainer container;
  late MockCategoryService service;

  setUpAll(() {
    registerFallbackValue(CategoryHost.expense);
    registerFallbackValue(
      CategoryInsDto(name: 'fallback', host: CategoryHost.expense),
    );
    registerFallbackValue(
      CategoryUpdDto(id: 'fallback', name: 'fallback', host: CategoryHost.expense),
    );
  });

  setUp(() {
    service = MockCategoryService();
    when(() => service.getAllCategories()).thenAnswer((_) async => []);
    when(
      () => service.getCategoriesByHost(any()),
    ).thenAnswer((_) async => []);
    container = ProviderContainer(
      overrides: [
        categoryServiceProvider.overrideWith((ref) async => service),
        loggerProvider.overrideWithValue(MockLogger()),
      ],
    );
    addTearDown(container.dispose);
  });

  CategoryCommandController controller() =>
      container.read(categoryCommandControllerProvider.notifier);

  FakeFormBuilderState buildFormState({
    String name = 'Test',
    int? transactionType = 1,
    String? description,
    bool valid = true,
  }) {
    return FakeFormBuilderState(
      valid: valid,
      fields: {
        'category_name': FakeFormFieldState(name),
        'transaction_type': FakeFormFieldState(transactionType),
        'category_description': FakeFormFieldState(description),
      },
    );
  }

  CategoryEntity buildEntity({
    String id = 'cat-1',
    String name = 'Test',
    int? iconCodePoint,
    String? color,
    CategoryHost host = CategoryHost.expense,
  }) {
    return CategoryEntity(
      id: id,
      coupleId: 'couple-1',
      name: name,
      icon: iconCodePoint?.toString(),
      color: color,
      createdAt: DateTime(2026, 1, 1),
      categoryHost: host,
      syncStatus: SyncStatus.synced,
      localUpdatedAt: DateTime(2026, 1, 1),
    );
  }

  group('selectIcon / selectColor', () {
    test('stores the selected icon and color', () {
      controller().selectIcon(TablerIcons.star_filled);
      controller().selectColor(const Color(0xFFF44336));
      expect(controller().selectedIcon, TablerIcons.star_filled);
      expect(controller().selectedColor, const Color(0xFFF44336));
    });
  });

  group('loadCategory', () {
    test(
      'parses icon and color from entity into the controller fields',
      () async {
        final codePoint = TablerIcons.star_filled.codePoint;
        when(() => service.getCategoryById('cat-1')).thenAnswer(
          (_) async => buildEntity(
            iconCodePoint: codePoint,
            color: '#FF5733',
          ),
        );

        final entity = await controller().loadCategory('cat-1');

        expect(entity?.id, 'cat-1');
        expect(controller().selectedIcon?.codePoint, codePoint);
        expect(controller().selectedIcon?.fontFamily, 'TablerIcons');
        expect(controller().selectedColor, const Color(0xFFFF5733));
        verify(() => service.getCategoryById('cat-1')).called(1);
      },
    );

    test('keeps previous selection when entity has no icon/color', () async {
      when(
        () => service.getCategoryById('cat-1'),
      ).thenAnswer((_) async => buildEntity());
      final c = controller();
      c.selectIcon(TablerIcons.briefcase_filled);
      c.selectColor(const Color(0xFFF44336));

      await c.loadCategory('cat-1');

      expect(c.selectedIcon, TablerIcons.briefcase_filled);
      expect(c.selectedColor, const Color(0xFFF44336));
    });

    test('returns null when category does not exist', () async {
      when(() => service.getCategoryById(any())).thenAnswer((_) async => null);

      final entity = await controller().loadCategory('missing');

      expect(entity, isNull);
    });
  });

  group('submit - create', () {
    test('creates the category, builds the DTO and invalidates the lists',
        () async {
      when(() => service.createCategory(any())).thenAnswer((_) async => 'cat-1');
      final c = controller();
      c.selectIcon(TablerIcons.star_filled);
      c.selectColor(const Color(0xFFF44336));

      await c.submit(buildFormState());

      final state = container.read(categoryCommandControllerProvider);
      expect(state, isA<AsyncData>());
      expect((state as AsyncData).value, 'cat-1');

      final dto =
          verify(() => service.createCategory(captureAny())).captured.single
              as CategoryInsDto;
      expect(dto.name, 'Test');
      expect(dto.host, CategoryHost.expense);
      expect(dto.icon, TablerIcons.star_filled.codePoint.toString());
      expect(dto.color, '#FFF44336');
      expect(dto.status, SyncStatus.pendingCreate);
      expect(dto.shortDescription, isNull);

      final list = await container.read(allCategoriesListProvider.future);
      expect(list, isEmpty);
      verify(() => service.getAllCategories()).called(1);
    });

    test('maps transaction type 2 to income host', () async {
      when(() => service.createCategory(any())).thenAnswer((_) async => 'cat-1');

      await controller().submit(buildFormState(transactionType: 2));

      final dto =
          verify(() => service.createCategory(captureAny())).captured.single
              as CategoryInsDto;
      expect(dto.host, CategoryHost.income);
    });

    test('sets state to null data when service returns empty id', () async {
      when(() => service.createCategory(any())).thenAnswer((_) async => '');

      await controller().submit(buildFormState());

      expect(
        container.read(categoryCommandControllerProvider),
        const AsyncData<dynamic>(null),
      );
    });

    test('does nothing when validation fails', () async {
      await controller().submit(buildFormState(valid: false));

      verifyNever(() => service.createCategory(any()));
      expect(
        container.read(categoryCommandControllerProvider),
        const AsyncData<dynamic>(null),
      );
    });

    test('does nothing when form state is null', () async {
      await controller().submit(null);

      verifyNever(() => service.createCategory(any()));
    });
  });

  group('submit - update', () {
    test('updates the category, builds the DTO and invalidates the lists',
        () async {
      when(() => service.updateCategory(any())).thenAnswer((_) async => true);
      final c = controller();
      c.selectIcon(TablerIcons.star_filled);
      c.selectColor(const Color(0xFFF44336));

      await c.submit(buildFormState(description: 'Mi descripción'),
          categoryId: 'cat-1');

      final state = container.read(categoryCommandControllerProvider);
      expect(state, isA<AsyncData>());
      expect((state as AsyncData).value, isTrue);

      final dto =
          verify(() => service.updateCategory(captureAny())).captured.single
              as CategoryUpdDto;
      expect(dto.id, 'cat-1');
      expect(dto.name, 'Test');
      expect(dto.host, CategoryHost.expense);
      expect(dto.icon, TablerIcons.star_filled.codePoint.toString());
      expect(dto.color, '#FFF44336');
      expect(dto.shortDescription, 'Mi descripción');

      final list = await container.read(categoriesByHostProvider(
        CategoryHost.expense,
      ).future);
      expect(list, isEmpty);
      verify(() => service.getCategoriesByHost(CategoryHost.expense)).called(1);
    });

    test('sets AsyncError state when service throws', () async {
      when(
        () => service.updateCategory(any()),
      ).thenThrow(Exception('boom'));

      await controller().submit(buildFormState(), categoryId: 'cat-1');

      expect(
        container.read(categoryCommandControllerProvider),
        isA<AsyncError>(),
      );
    });
  });
}