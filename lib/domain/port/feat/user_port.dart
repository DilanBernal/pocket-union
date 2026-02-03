import 'package:pocket_union/domain/models/user.dart';

abstract class UserPort {
  Future<bool> upsertUser(DomainUser user);
}
