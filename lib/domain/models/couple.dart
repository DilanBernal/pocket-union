import 'package:pocket_union/domain/enum/couple_usable_state.dart';

class Couple {
  final String id;
  final DateTime createdAt;
  final String? user1Id;
  final String? user2Id;
  final CoupleUsableState isUsable;

  Couple({
    required this.id,
    required this.createdAt,
    this.user1Id,
    this.user2Id,
    this.isUsable = CoupleUsableState.waiting,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user1_id': user1Id,
      'user2_id': user2Id,
      'is_usable': isUsable.value,
    };
  }

  factory Couple.fromMap(Map<String, dynamic> map) {
    return Couple(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      user1Id: map['user1_id'],
      user2Id: map['user2_id'],
      isUsable: CoupleUsableState.fromString(map['is_usable']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user1_id': user1Id,
      'user2_id': user2Id,
      'is_usable': isUsable.value,
    };
  }

  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      isUsable: CoupleUsableState.fromString(json['is_usable']),
    );
  }
}
