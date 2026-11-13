
import '../entities/user_entity.dart';

abstract class UserLocalPort {
  Future<bool> upsertUser(UserEntity user);

  Future<UserEntity?> getUserById(String id);

  Future<UserEntity?> getCurrentUser();

  Future<List<UserEntity>> getByFilter(UserEntity filter);

  Future<bool> deleteAllUsers();
}