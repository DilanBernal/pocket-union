class UserEntity {
  final String id;
  final String fullName;
  String? avatarUrl;
  bool inCloud;
  DateTime? lastSync;

  UserEntity({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.lastSync,
    required this.inCloud,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'in_cloud': inCloud == true ? 1 : 0,
      'avatar_url': avatarUrl,
      'last_sync': lastSync?.toIso8601String(),
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      fullName: map['full_name'] ?? map['fullName'] ?? '',
      inCloud: (map['in_cloud'] ?? map['inCloud'] ?? 0) == 1,
      avatarUrl: map['avatar_url'] ?? map['avatarUrl'],
      lastSync: (map['last_sync'] ?? map['lastSync']) != null
          ? DateTime.parse(map['last_sync'] ?? map['lastSync'])
          : DateTime.now(),
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      fullName: json['full_name'] ?? json['name'],
      inCloud: json['inCloud'] == 1,
      avatarUrl: json['avatarUrl'],
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'inCloud': inCloud == true ? 1 : 0,
      'avatarUrl': avatarUrl,
      'lastSync': lastSync?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DomainUser(id: $id, fullName: $fullName, inCloud: $inCloud, avatarUrl: $avatarUrl, lastSync: $lastSync)';
  }
}
