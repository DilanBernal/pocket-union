import 'dart:convert';

import 'package:pocket_union/domain/enum/sync_status.dart';

class RecurrentIncome {
  final String id;
  final String coupleId;
  String name;
  final double amount;
  final String? userRecipientId;
  final List<int>? recurrentInfo;
  final DateTime createdAt;
  SyncStatus syncStatus;

  RecurrentIncome({
    required this.id,
    required this.coupleId,
    required this.name,
    required this.amount,
    this.userRecipientId,
    this.recurrentInfo,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'amount': (amount * 100).round(),
      'user_recipient_id': userRecipientId,
      'recurrent_info': recurrentInfo != null
          ? jsonEncode(recurrentInfo)
          : null,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus.value,
    };
  }

  factory RecurrentIncome.fromMap(Map<String, dynamic> map) {
    return RecurrentIncome(
      id: map['id'],
      coupleId: map['couple_id'],
      name: map['name'],
      amount: (map['amount'] as num).toDouble() / 100,
      userRecipientId: map['user_recipient_id'],
      recurrentInfo: map['recurrent_info'] != null
          ? (jsonDecode(map['recurrent_info']) as List<dynamic>)
                .map((e) => e as int)
                .toList()
          : null,
      createdAt: DateTime.parse(map['created_at']),
      syncStatus: SyncStatus.fromString(
        (map['sync_status'] as String? ?? 'pending').toUpperCase(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'amount': amount,
      'user_recipient_id': userRecipientId,
      'recurrent_info': recurrentInfo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RecurrentIncome.fromJson(Map<String, dynamic> json) {
    return RecurrentIncome(
      id: json['id'],
      coupleId: json['couple_id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      userRecipientId: json['user_recipient_id'],
      recurrentInfo: (json['recurrent_info'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      syncStatus: SyncStatus.fromString(
        (json['sync_status'] as String? ?? 'pending').toUpperCase(),
      ),
    );
  }
}
