class User {
  final String id;
  final String name;
  double balance;
  bool inCloud;

  User(
      {required this.id,
      required this.name,
      required this.balance,
      required this.inCloud});
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'balance': balance,
      'inCloud': inCloud == true ? 1 : 0
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'],
        name: map['name'],
        balance: (map['balance'] as num).toDouble(),
        inCloud: map['inCloud'] == 1);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        balance: json['balance'],
        inCloud: json['inCloud'] == 1
    );
  }
}
