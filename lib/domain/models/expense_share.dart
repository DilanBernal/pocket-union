class ExpenseShare {
  final String id;
  final DateTime createdAt;
  final String expenseId;
  final String userId;
  final double sharePercentage;
  bool inCloud;

  ExpenseShare({
    required this.id,
    required this.createdAt,
    required this.expenseId,
    required this.userId,
    required this.sharePercentage,
    required this.inCloud,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'expense_id': expenseId,
      'user_id': userId,
      'share_percentage': sharePercentage,
      'inCloud': inCloud ? 1 : 0,
    };
  }

  factory ExpenseShare.fromMap(Map<String, dynamic> map) {
    return ExpenseShare(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      expenseId: map['expense_id'],
      userId: map['user_id'],
      sharePercentage: (map['share_percentage'] as num).toDouble(),
      inCloud: map['inCloud'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'expense_id': expenseId,
      'user_id': userId,
      'share_percentage': sharePercentage,
    };
  }

  factory ExpenseShare.fromJson(Map<String, dynamic> json) {
    return ExpenseShare(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      expenseId: json['expense_id'],
      userId: json['user_id'],
      sharePercentage: (json['share_percentage'] as num).toDouble(),
      inCloud: json['inCloud'] == 1,
    );
  }
}
