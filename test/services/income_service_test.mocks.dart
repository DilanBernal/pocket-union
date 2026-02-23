// ignore_for_file: type=lint
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:mockito/mockito.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/feat/income_port.dart';
import 'package:pocket_union/dto/new_income_dto.dart';

class MockIncomePort extends Mock implements IncomePort {
  @override
  Future<String> createIncome(NewIncomeDto? dto) =>
      super.noSuchMethod(
        Invocation.method(#createIncome, [dto]),
        returnValue: Future.value(''),
        returnValueForMissingStub: Future.value(''),
      ) as Future<String>;

  @override
  Future<List<Income>> getAllIncomes() =>
      super.noSuchMethod(
        Invocation.method(#getAllIncomes, []),
        returnValue: Future.value(<Income>[]),
        returnValueForMissingStub: Future.value(<Income>[]),
      ) as Future<List<Income>>;
}
