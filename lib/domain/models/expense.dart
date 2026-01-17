class Expense {
  final String id;
  final String coupleId;
  final String createdBy;
  String name;
  DateTime? transactionDate;
  String? description;
  final double amount;
  final String? categoryId;
  final bool isFixed;
  final int importanceLevel;
  final bool isPlaned;
  final DateTime createdAt;
  bool inCloud;

  Expense({
    required this.id,
    required this.coupleId,
    required this.createdBy,
    required this.name,
    this.transactionDate,
    this.description,
    required this.amount,
    this.categoryId,
    this.isFixed = false,
    required this.importanceLevel,
    this.isPlaned = false,
    required this.createdAt,
    required this.inCloud,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'created_by': createdBy,
      'name': name,
      'transaction_date': transactionDate?.toIso8601String(),
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'is_fixed': isFixed ? 1 : 0,
      'importance_level': importanceLevel,
      'is_planed': isPlaned ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'inCloud': inCloud ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      coupleId: map['couple_id'],
      createdBy: map['created_by'],
      name: map['name'],
      transactionDate: map['transaction_date'] != null
          ? DateTime.parse(map['transaction_date'])
          : null,
      description: map['description'],
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'],
      isFixed: map['is_fixed'] == 1,
      importanceLevel: map['importance_level'],
      isPlaned: map['is_planed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      inCloud: map['inCloud'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'created_by': createdBy,
      'name': name,
      'transaction_date': transactionDate?.toIso8601String(),
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'is_fixed': isFixed,
      'importance_level': importanceLevel,
      'is_planed': isPlaned,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      coupleId: json['couple_id'],
      createdBy: json['created_by'],
      name: json['name'],
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : null,
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'],
      isFixed: json['is_fixed'] ?? false,
      importanceLevel: json['importance_level'],
      isPlaned: json['is_planed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      inCloud: json['inCloud'] == 1,
    );
  }
}
