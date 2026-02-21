import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/dto/new_couple_dto.dart';

abstract class CouplePort {
  Future acceptCouple(NewCoupleDto coupleDto);
  Future declineCouple();
  Future<Couple?> getCouple();
}
