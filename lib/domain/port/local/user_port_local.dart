import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/dto/filter/user_filter_dto.dart';

abstract class UserLocalPort {
  Future<bool> upsertUser(DomainUser user);

  Future<DomainUser?> getUserById(String id);

  Future<DomainUser?> getCurrentUser();

  Future<List<DomainUser>> getByFilter(UserFilterDto filter);

  Future<bool> deleteAllUsers();
}
