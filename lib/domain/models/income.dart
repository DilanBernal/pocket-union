import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';

class Income {
  final String id;
  final String? coupleId;
  String name;
  DateTime transactionDate;
  String? description;
  final double amount;
  List<String> categoryIds;
  List<Category> categories = [];
  final bool isRecurring;
  final bool isReceived;
  final Map<String, dynamic>? receivedIn;
  final DateTime createdAt;

  /// Quién recibió el dinero. null = ambos (NOSOTROS).
  final String? userRecipientId;
  SyncStatus syncStatus;
  bool isDeleted;

  Income({
    required this.id,
    this.coupleId,
    required this.name,
    required this.transactionDate,
    this.description,
    required this.amount,
    this.categoryIds = const [],
    this.isRecurring = false,
    this.isReceived = true,
    this.receivedIn,
    required this.createdAt,
    this.userRecipientId,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });

  /// Mapa para la tabla `income` en SQLite (sin campos de income_info ni income_category).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'transaction_date': transactionDate.toIso8601String(),
      'description': description,
      'amount': (amount * 100).round(),
      'is_received': isReceived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'user_recipient_id': userRecipientId,
      'sync_status': syncStatus.value,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Mapa para la tabla `income_info` en SQLite.
  Map<String, dynamic> toIncomeInfoMap() {
    return {
      'income_id': id,
      'is_recurring': isRecurring ? 1 : 0,
      'received_in': receivedIn,
      'is_received': isReceived ? 1 : 0,
    };
  }

  /// Lee desde SQLite donde amount está almacenado en centavos.
  /// [map] contiene campos de income LEFT JOIN income_info.
  /// [categoryIds] se provee aparte desde income_category.
  factory Income.fromMap(
    Map<String, dynamic> map, {
    List<String> categoryIds = const [],
  }) {
    return Income(
      id: map['id'],
      coupleId: map['couple_id'],
      name: map['name'],
      transactionDate: DateTime.parse(map['transaction_date']),
      description: map['description'],
      amount: (map['amount'] as num).toDouble() / 100,
      categoryIds: categoryIds,
      isRecurring: map['is_recurring'] == 1,
      isReceived: map['is_received'] == 1,
      receivedIn: map['received_in'],
      createdAt: DateTime.parse(map['created_at']),
      userRecipientId: map['user_recipient_id'],
      syncStatus: SyncStatus.fromString(
        (map['sync_status'] as String? ?? 'pending').toUpperCase(),
      ),
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'transaction_date': transactionDate.toIso8601String(),
      'description': description,
      'amount': amount,
      'category_ids': categoryIds,
      'is_recurring': isRecurring,
      'is_received': isReceived,
      'received_in': receivedIn,
      'created_at': createdAt.toIso8601String(),
      'user_recipient_id': userRecipientId,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      coupleId: json['couple_id'],
      name: json['name'],
      transactionDate: DateTime.parse(json['transaction_date']),
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      categoryIds:
          (json['category_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isRecurring: json['is_recurring'] ?? false,
      isReceived: json['is_received'] ?? true,
      receivedIn: json['received_in'],
      createdAt: DateTime.parse(json['created_at']),
      userRecipientId: json['user_recipient_id'],
      syncStatus: SyncStatus.fromString(
        (json['sync_status'] as String? ?? 'pending').toUpperCase(),
      ),
      isDeleted: json['is_deleted'] == 1 || json['is_deleted'] == true,
    );
  }
}
