import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/dto/new_income_dto.dart';

abstract class IncomePort {
  Future<List<Income>> getAllIncomes();
  Future<String> createIncome(NewIncomeDto dto);
}
