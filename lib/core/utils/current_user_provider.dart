import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_provider.g.dart';

@riverpod
Future<UserEntity?> currentUser(Ref ref) async {
  final authService = await ref.watch(authServiceProvider.future);
  var currentUserResponse = await authService.getCurrentUser();
  switch (currentUserResponse) {
    case Success<UserEntity?>(:final value):
      return value;
    case Failure<UserEntity?>():
      return null;
  }
}
