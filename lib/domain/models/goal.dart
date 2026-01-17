class Goal {
  final String id;
  final DateTime createdAt;
  final String coupleId;
  String name;
  final double targetAmount;
  double currentAmount;
  DateTime? deadline;
  String? description;
  bool inCloud;

  Goal({
    required this.id,
    required this.createdAt,
    required this.coupleId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.description,
    required this.inCloud,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'couple_id': coupleId,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String().split('T').first,
      'description': description,
      'inCloud': inCloud ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      coupleId: map['couple_id'],
      name: map['name'],
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0,
      deadline:
          map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      description: map['description'],
      inCloud: map['inCloud'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'couple_id': coupleId,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String().split('T').first,
      'description': description,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      coupleId: json['couple_id'],
      name: json['name'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      description: json['description'],
      inCloud: json['inCloud'] == 1,
    );
  }

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) : 0;

  bool get isCompleted => currentAmount >= targetAmount;
}
