import '../enums/couple_usable_state.dart';

class CoupleEntity {
  final String id;
  final DateTime createdAt;
  final String? user1Id;
  final String? user2Id;
  final CoupleUsableState isUsable;

  CoupleEntity({
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

  factory CoupleEntity.fromMap(Map<String, dynamic> map) {
    return CoupleEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      user1Id: map['user1_id'],
      user2Id: map['user2_id'],
      isUsable: CoupleUsableState.fromString(map['is_usable'] ?? 'WAITING'),
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

  factory CoupleEntity.fromJson(Map<String, dynamic> json) {
    return CoupleEntity(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      isUsable: CoupleUsableState.fromString(json['is_usable'] ?? 'WAITING'),
    );
  }
}
