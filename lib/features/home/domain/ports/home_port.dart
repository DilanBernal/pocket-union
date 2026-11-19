import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/home/domain/entities/couple_balance_entity.dart';
import 'package:pocket_union/features/home/domain/entities/couple_transaction_entity.dart';
import 'package:pocket_union/features/home/domain/entities/user_balance_entity.dart';

abstract class HomePort {
  Future<AppResponse<CoupleBalanceEntity>> getCoupleBalance();
  Future<AppResponse<UserBalanceEntity>> getUserBalance();

  Future<AppResponse<List<CoupleTransactionEntity>>> getRecentTransactions();
}
