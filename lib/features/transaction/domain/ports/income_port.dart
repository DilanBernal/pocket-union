import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/transaction/application/dto/income_ins_dto.dart';
import 'package:pocket_union/features/transaction/domain/entities/income_entity.dart';

abstract class IncomePort {
  Future<AppResponse<String?>> createIncome(IncomeInsDto data);
  Future<List<IncomeEntity>> getLocalIncomes();
  Future<void> synchronizeIncomes();
  Future<AppResponse<bool>> deleteIncome(String id);
}
