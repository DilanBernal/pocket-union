import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/transaction/application/dto/income_ins_dto.dart';

abstract class IncomePort {
  Future<AppResponse<String?>> createIncome(IncomeInsDto data);
}
