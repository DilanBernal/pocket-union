import 'package:pocket_union/domain/enum/sync_status.dart';

class Expense {
  final String id;
  final String coupleId;
  final String createdBy;
  String name;
  DateTime? transactionDate;
  String? description;
  final double amount;
  final List<String> categoryIds;
  final bool isFixed;
  final int importanceLevel;
  final bool isPlaned;
  final DateTime createdAt;
  SyncStatus syncStatus;
  DateTime? lastSyncAt;
  DateTime localUpdatedAt;
  bool isDeleted;

  Expense({
    required this.id,
    required this.coupleId,
    required this.createdBy,
    required this.name,
    this.transactionDate,
    this.description,
    required this.amount,
    this.categoryIds = const [],
    this.isFixed = false,
    required this.importanceLevel,
    this.isPlaned = false,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncAt,
    DateTime? localUpdatedAt,
    this.isDeleted = false,
  }) : localUpdatedAt = localUpdatedAt ?? DateTime.now();

  /// Mapa para la tabla `expense` en SQLite (sin campos de expense_info ni expense_category).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'created_by': createdBy,
      'name': name,
      'transaction_date': transactionDate?.toIso8601String(),
      'description': description,
      'amount': (amount * 100).round(),
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus.value,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'local_updated_at': localUpdatedAt.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Mapa para la tabla `expense_info` en SQLite.
  Map<String, dynamic> toExpenseInfoMap() {
    return {
      'id': id,
      'is_fixed': isFixed ? 1 : 0,
      'importance_level': importanceLevel,
      'is_planed': isPlaned ? 1 : 0,
    };
  }

  /// Lee desde SQLite con datos del JOIN expense + expense_info.
  /// [categoryIds] se provee aparte desde expense_category.
  factory Expense.fromMap(
    Map<String, dynamic> map, {
    List<String> categoryIds = const [],
  }) {
    return Expense(
      id: map['id'],
      coupleId: map['couple_id'],
      createdBy: map['created_by'],
      name: map['name'],
      transactionDate: map['transaction_date'] != null
          ? DateTime.parse(map['transaction_date'])
          : null,
      description: map['description'],
      amount: (map['amount'] as num).toDouble() / 100,
      categoryIds: categoryIds,
      isFixed: map['is_fixed'] == 1,
      importanceLevel: map['importance_level'] ?? 0,
      isPlaned: map['is_planed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      syncStatus: SyncStatus.fromString(
        (map['sync_status'] as String? ?? 'pending').toUpperCase(),
      ),
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'])
          : null,
      localUpdatedAt: map['local_updated_at'] != null
          ? DateTime.parse(map['local_updated_at'])
          : null,
      isDeleted: map['is_deleted'] == 1,
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
      'category_ids': categoryIds,
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
      categoryIds:
          (json['category_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFixed: json['is_fixed'] ?? false,
      importanceLevel: json['importance_level'] ?? 0,
      isPlaned: json['is_planed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      syncStatus: SyncStatus.fromString(
        (json['sync_status'] as String? ?? 'pending').toUpperCase(),
      ),
      isDeleted: json['is_deleted'] == 1 || json['is_deleted'] == true,
    );
  }
}
