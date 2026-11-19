import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/utils/categories_list_provider.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/features/reference/application/services/category_service.dart';
import 'package:pocket_union/features/reference/category/dtos/category_ins_dto.dart';
import 'package:pocket_union/features/reference/category/dtos/category_upd_dto.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_command_controller.g.dart';

@riverpod
class CategoryCommandController extends _$CategoryCommandController {
  IconData? selectedIcon;
  Color? selectedColor;

  @override
  AsyncValue build() => const AsyncData(null);

  void selectIcon(IconData icon) {
    selectedIcon = icon;
  }

  void selectColor(Color color) {
    selectedColor = color;
  }

  Future<CategoryEntity?> loadCategory(String categoryId) async {
    final categoryService = await ref.read(categoryServiceProvider.future);
    final category = await categoryService.getCategoryById(categoryId);
    if (category != null) {
      if (category.icon != null) {
        selectedIcon = IconData(
          int.parse(category.icon!),
          fontFamily: 'TablerIcons',
        );
      }
      if (category.color != null) {
        selectedColor = Color(
          int.parse(category.color!.substring(1), radix: 16) + 0xFF000000,
        );
      }
    }
    return category;
  }

  Future<void> submit(FormBuilderState? formState, {String? categoryId}) async {
    if (formState == null || !formState.saveAndValidate()) {
      return;
    }
    try {
      final host = formState.fields['transaction_type']?.value == 1
          ? CategoryHost.expense
          : CategoryHost.income;
      final icon =
          selectedIcon?.codePoint.toString() ??
          TablerIcons.currency_dollar.codePoint.toString();
      final color = _colorToHex(selectedColor ?? Colors.blue);

      if (categoryId != null) {
        await _updateCategory(
          CategoryUpdDto(
            id: categoryId,
            name: formState.fields['category_name']!.value,
            host: host,
            icon: icon,
            color: color,
            shortDescription:
                formState.fields['category_description']?.value,
          ),
        );
      } else {
        await _createCategory(
          CategoryInsDto(
            name: formState.fields['category_name']!.value,
            host: host,
            icon: icon,
            color: color,
            syncStatuss: SyncStatus.pendingCreate,
            shortDescription:
                formState.fields['category_description']?.value,
          ),
        );
      }
      ref.invalidate(allCategoriesListProvider);
      ref.invalidate(categoriesByHostProvider);
    } catch (e, st) {
      ref.read(loggerProvider).error('Error saving category', error: e, stackTrace: st);
      state = AsyncError(e, st);
    }
  }

  Future<void> _createCategory(CategoryInsDto request) async {
    state = const AsyncLoading();
    try {
      final categoryService = await ref.read(categoryServiceProvider.future);
      final result = await categoryService.createCategory(request);
      if (result.isEmpty) {
        state = AsyncData(null);
        return;
      }
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
      return;
    }
  }

  Future<void> _updateCategory(CategoryUpdDto request) async {
    state = const AsyncLoading();
    try {
      final categoryService = await ref.read(categoryServiceProvider.future);
      final result = await categoryService.updateCategory(request);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
      return;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}