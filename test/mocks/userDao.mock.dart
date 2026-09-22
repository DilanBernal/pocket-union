import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/features/auth/domain/ports/user_port_local.dart';

class MockUserDao extends Mock implements UserLocalPort {}
