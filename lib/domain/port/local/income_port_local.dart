import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/dto/filter/income_filter_dto.dart';
import 'package:pocket_union/dto/new_income_dto.dart';

abstract class IncomeLocalPort {
  Future<String> createIncome(NewIncomeDto dto);

  Future<Income?> getIncomeById(String id);

  Future<List<Income>> getAllIncomes();

  Future<List<Income>> getByFilter(IncomeFilterDto filter);

  Future<bool> updateIncome(Income income);

  Future<bool> deleteIncome(String id);
}
