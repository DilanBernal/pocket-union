import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:pocket_union/features/home/application/services/home_service.dart';
import 'package:pocket_union/features/home/domain/entities/couple_balance_entity.dart';
import 'package:pocket_union/features/home/domain/entities/couple_transaction_entity.dart';
import 'package:pocket_union/features/home/domain/entities/user_balance_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  AsyncValue build() => const AsyncData(null);

  UserEntity? _actualUser;
  UserEntity? _actualPartnerUser;

  Future<UserEntity?> getActualUser({bool forceRefresh = false}) async {
    if (_actualUser != null && !forceRefresh) {
      return _actualUser;
    }
    final logger = ref.read(loggerProvider);
    try {
      final userService = await ref.read(authServiceProvider.future);
      final userResponse = await userService.getCurrentUser();
      logger.info('User response: $userResponse');
      return switch (userResponse) {
        Success<UserEntity?>() => _actualUser = userResponse.value,
        Failure<UserEntity?>() => null,
      };
    } catch (e) {
      logger.error('Error getting actual user: $e');
      return null;
    }
  }

  Future<UserEntity?> getActualPartnerUser({bool forceRefresh = false}) async {
    if (_actualPartnerUser != null && !forceRefresh) {
      return _actualPartnerUser;
    }
    final logger = ref.read(loggerProvider);
    try {
      final userService = await ref.read(authServiceProvider.future);
      final userResponse = await userService.getCurrentUserPartner();
      logger.info('User response: $userResponse');
      return switch (userResponse) {
        Success<UserEntity?>() => _actualPartnerUser = userResponse.value,
        Failure<UserEntity?>() => null,
      };
    } catch (e) {
      logger.error('Error getting actual partner user: $e');
      return null;
    }
  }
}

class HomeDashboardData {
  final UserEntity? user;
  final UserEntity? partner;
  final CoupleBalanceEntity coupleBalance;
  final UserBalanceEntity personalBalance;
  final List<CoupleTransactionEntity> recentTransactions;

  const HomeDashboardData({
    required this.user,
    required this.partner,
    required this.coupleBalance,
    required this.personalBalance,
    required this.recentTransactions,
  });
}

@riverpod
Future<HomeDashboardData> homeDashboard(Ref ref) async {
  final authService = await ref.watch(authServiceProvider.future);
  final homeService = await ref.watch(homeServiceProvider.future);

  final userResponse = await authService.getCurrentUser();
  final partnerResponse = await authService.getCurrentUserPartner();
  final coupleBalanceResponse = await homeService.getCoupleBalance();
  final personalBalanceResponse = await homeService.getUserBalance();
  final transactionsResponse = await homeService.getRecentTransactions();

  final user = switch (userResponse) {
    Success<UserEntity?>() => userResponse.value,
    Failure<UserEntity?>() => null,
  };
  final partner = switch (partnerResponse) {
    Success<UserEntity?>() => partnerResponse.value,
    Failure<UserEntity?>() => null,
  };
  final coupleBalance = switch (coupleBalanceResponse) {
    Success<CoupleBalanceEntity>() => coupleBalanceResponse.value,
    Failure<CoupleBalanceEntity>() => const CoupleBalanceEntity.zero(
      coupleId: '',
    ),
  };
  final personalBalance = switch (personalBalanceResponse) {
    Success<UserBalanceEntity>() => personalBalanceResponse.value,
    Failure<UserBalanceEntity>() => const UserBalanceEntity.zero(userId: ''),
  };
  final recentTransactions = switch (transactionsResponse) {
    Success<List<CoupleTransactionEntity>>() => transactionsResponse.value,
    Failure<List<CoupleTransactionEntity>>() =>
      const <CoupleTransactionEntity>[],
  };

  return HomeDashboardData(
    user: user,
    partner: partner,
    coupleBalance: coupleBalance,
    recentTransactions: recentTransactions,
    personalBalance: personalBalance,
  );
}
