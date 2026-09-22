import 'package:pocket_union/features/transaction/application/dto/income_ins_dto.dart';

abstract class IncomePort {
  Future<void> createIncome(IncomeInsDto data);
}
