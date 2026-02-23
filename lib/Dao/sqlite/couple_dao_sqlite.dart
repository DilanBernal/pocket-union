import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/port/auth/couple_port.dart';
import 'package:pocket_union/dto/new_couple_dto.dart';

class CoupleDaoSqlite extends CouplePort {
  @override
  Future acceptCouple(NewCoupleDto coupleDto) {
    // TODO: implement acceptCouple
    throw UnimplementedError();
  }

  @override
  Future createCouple(NewCoupleDto coupleDto) {
    // TODO: implement createCouple
    throw UnimplementedError();
  }

  @override
  Future declineCouple() {
    // TODO: implement declineCouple
    throw UnimplementedError();
  }

  @override
  Future<Couple?> getCouple() {
    // TODO: implement getCouple
    throw UnimplementedError();
  }
}
