class GoalContribution {
  final String id;
  final String goalId;
  final String userId;
  final double amount;
  DateTime? contributionDate;
  final DateTime createdAt;
  bool inCloud;

  GoalContribution({
    required this.id,
    required this.goalId,
    required this.userId,
    this.amount = 50,
    this.contributionDate,
    required this.createdAt,
    required this.inCloud,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'user_id': userId,
      'ammount': amount,
      'contribution_date': contributionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'inCloud': inCloud ? 1 : 0,
    };
  }

  factory GoalContribution.fromMap(Map<String, dynamic> map) {
    return GoalContribution(
      id: map['id'],
      goalId: map['goal_id'],
      userId: map['user_id'],
      amount: (map['ammount'] as num?)?.toDouble() ?? 50,
      contributionDate: map['contribution_date'] != null
          ? DateTime.parse(map['contribution_date'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      inCloud: map['inCloud'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'user_id': userId,
      'ammount': amount,
      'contribution_date': contributionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'],
      goalId: json['goal_id'],
      userId: json['user_id'],
      amount: (json['ammount'] as num?)?.toDouble() ?? 50,
      contributionDate: json['contribution_date'] != null
          ? DateTime.parse(json['contribution_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      inCloud: json['inCloud'] == 1,
    );
  }
}
