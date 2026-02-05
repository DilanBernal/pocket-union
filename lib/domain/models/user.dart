class DomainUser {
  final String id;
  final String fullName;
  double balance;
  String? avatarUrl;
  bool inCloud;
  DateTime? lastSync;

  DomainUser(
      {required this.id,
      required this.fullName,
      required this.balance,
      this.avatarUrl,
      this.lastSync,
      required this.inCloud});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'user_balance': balance,
      'in_cloud': inCloud == true ? 1 : 0,
      'avatar_url': avatarUrl,
      'last_sync': lastSync?.toIso8601String(),
    };
  }

  factory DomainUser.fromMap(Map<String, dynamic> map) {
    return DomainUser(
      id: map['id'],
      fullName: map['full_name'] ?? map['fullName'] ?? '',
      balance: (map['user_balance'] ?? map['balance'] as num? ?? 0).toDouble(),
      inCloud: (map['in_cloud'] ?? map['inCloud'] ?? 0) == 1,
      avatarUrl: map['avatar_url'] ?? map['avatarUrl'],
      lastSync:
          (map['last_sync'] ?? map['lastSync']) != null ? DateTime.parse(map['last_sync'] ?? map['lastSync']) : null,
    );
  }

  factory DomainUser.fromJson(Map<String, dynamic> json) {
    return DomainUser(
      id: json['id'],
      fullName: json['full_name'] ?? json['name'],
      balance: (json['balance'] as num).toDouble(),
      inCloud: json['inCloud'] == 1,
      avatarUrl: json['avatarUrl'],
      lastSync:
          json['lastSync'] != null ? DateTime.parse(json['lastSync']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'balance': balance,
      'inCloud': inCloud == true ? 1 : 0,
      'avatarUrl': avatarUrl,
      'lastSync': lastSync?.toIso8601String(),
    };
  }
}
