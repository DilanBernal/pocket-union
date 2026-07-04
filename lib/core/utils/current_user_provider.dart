import 'package:pocket_union/features/auth/application/dao/user_dao_local.dart';
import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_provider.g.dart';

@riverpod
Future<UserEntity?> currentUser(Ref ref) async {
  final userDao = await ref.read(userLocalPortProvider.future);
  return await userDao.getCurrentUser();
}
