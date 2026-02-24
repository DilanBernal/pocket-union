import 'package:pocket_union/domain/enum/sync_status.dart';

class Income {
  final String id;
  final String? coupleId;
  String name;
  DateTime transactionDate;
  String? description;
  final double amount;
  final String? categoryId;
  final bool isRecurring;
  final Map<String, dynamic>? recurrenceInterval;
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
    this.categoryId,
    this.isRecurring = false,
    this.recurrenceInterval,
    this.isReceived = true,
    this.receivedIn,
    required this.createdAt,
    this.userRecipientId,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'transaction_date': transactionDate.toIso8601String(),
      'description': description,
      'amount': (amount * 100).round(),
      'category_id': categoryId,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_interval': recurrenceInterval,
      'is_received': isReceived ? 1 : 0,
      'received_in': receivedIn,
      'created_at': createdAt.toIso8601String(),
      'user_recipient_id': userRecipientId,
      'sync_status': syncStatus.value,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Lee desde SQLite donde amount está almacenado en centavos.
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      coupleId: map['couple_id'],
      name: map['name'],
      transactionDate: DateTime.parse(map['transaction_date']),
      description: map['description'],
      amount: (map['amount'] as num).toDouble() / 100,
      categoryId: map['category_id'],
      isRecurring: map['is_recurring'] == 1,
      recurrenceInterval: map['recurrence_interval'],
      isReceived: map['is_received'] == 1,
      receivedIn: map['received_in'],
      createdAt: DateTime.parse(map['created_at']),
      userRecipientId: map['user_recipient_id'],
      syncStatus: SyncStatus.fromString(
          (map['sync_status'] as String? ?? 'pending').toUpperCase()),
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
      'category_id': categoryId,
      'is_recurring': isRecurring,
      'recurrence_interval': recurrenceInterval,
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
      categoryId: json['category_id'],
      isRecurring: json['is_recurring'] ?? false,
      recurrenceInterval: json['recurrence_interval'],
      isReceived: json['is_received'] ?? true,
      receivedIn: json['received_in'],
      createdAt: DateTime.parse(json['created_at']),
      userRecipientId: json['user_recipient_id'],
      syncStatus: SyncStatus.fromString(
          (json['sync_status'] as String? ?? 'pending').toUpperCase()),
      isDeleted: json['is_deleted'] == 1 || json['is_deleted'] == true,
    );
  }
}
