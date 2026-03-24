import 'package:pocket_union/domain/models/recurrent_income.dart';
import 'package:pocket_union/dto/new_recurrent_income_dto.dart';

abstract class RecurrentIncomeLocalPort {
  Future<String> createRecurrentIncome(NewRecurrentIncomeDto dto);
  Future<RecurrentIncome?> getRecurrentIncomeById(String id);
  Future<List<RecurrentIncome>> getAllRecurrentIncomes();
  Future<bool> updateRecurrentIncome(RecurrentIncome recurrentIncome);
  Future<bool> deleteRecurrentIncome(String id);
}
