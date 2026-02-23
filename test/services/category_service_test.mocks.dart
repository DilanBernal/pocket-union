// ignore_for_file: type=lint
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:mockito/mockito.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';

class MockCategoryPort extends Mock implements CategoryPort {
  @override
  Future<List<Category>> getCategories() =>
      super.noSuchMethod(
        Invocation.method(#getCategories, []),
        returnValue: Future.value(<Category>[]),
        returnValueForMissingStub: Future.value(<Category>[]),
      ) as Future<List<Category>>;

  @override
  Future<String> createCategory(NewCategoryDto? dto, String? coupleId) =>
      super.noSuchMethod(
        Invocation.method(#createCategory, [dto, coupleId]),
        returnValue: Future.value(''),
        returnValueForMissingStub: Future.value(''),
      ) as Future<String>;
}
