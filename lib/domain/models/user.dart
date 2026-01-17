class User {
  final String id;
  final String fullName;
  double balance;
  String? avatarUrl;
  bool inCloud;
  DateTime? lastSync;

  User(
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
      'balance': balance,
      'inCloud': inCloud == true ? 1 : 0,
      'avatarUrl': avatarUrl,
      'lastSync': lastSync?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['full_name'],
      balance: (map['balance'] as num).toDouble(),
      inCloud: map['inCloud'] == 1,
      avatarUrl: map['avatarUrl'],
      lastSync:
          map['lastSync'] != null ? DateTime.parse(map['lastSync']) : null,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
