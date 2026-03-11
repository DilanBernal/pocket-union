import 'package:pocket_union/domain/models/recurrent_income.dart';
import 'package:pocket_union/dto/new_recurrent_income_dto.dart';

abstract class IRecurrentIncomePort {
  Future<String> createRecurrentIncome(NewRecurrentIncomeDto dto);
  Future<List<RecurrentIncome>> getAllRecurrentIncomes();
}
