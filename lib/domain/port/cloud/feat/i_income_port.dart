import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/dto/new_income_dto.dart';

abstract class IIncomePort {
  Future<String> createIncome(NewIncomeDto dto);
  Future<List<Income>> getAllIncomes();
}
