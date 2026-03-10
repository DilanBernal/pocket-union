import 'package:pocket_union/domain/enum/couple_usable_state.dart';

class CoupleFilterDto {
  final String? id;
  final String? userId;
  final String? inviteCode;
  final CoupleUsableState? isUsable;

  CoupleFilterDto({this.id, this.userId, this.inviteCode, this.isUsable});
}
