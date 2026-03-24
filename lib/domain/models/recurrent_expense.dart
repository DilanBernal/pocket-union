import 'dart:convert';

import 'package:pocket_union/domain/enum/sync_status.dart';

class RecurrentExpense {
  final String id;
  final String coupleId;
  final String createdBy;
  String name;
  final double amount;
  final String? recurrentInfo;
  final DateTime createdAt;
  SyncStatus syncStatus;

  RecurrentExpense({
    required this.id,
    required this.coupleId,
    required this.createdBy,
    required this.name,
    required this.amount,
    this.recurrentInfo,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'created_by': createdBy,
      'name': name,
      'amount': (amount * 100).round(),
      'recurrent_info': recurrentInfo,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus.value,
    };
  }

  static String? _parseRecurrentInfo(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed) as List<dynamic>;
          return decoded
              .map((e) => e.toString() == '-1' ? '*' : e.toString())
              .join(' ');
        } catch (_) {
          return trimmed;
        }
      }

      return trimmed
          .split(RegExp(r'\s+'))
          .map((token) => token == '-1' ? '*' : token)
          .join(' ');
    }

    if (value is List) {
      return value
          .map((e) => e.toString() == '-1' ? '*' : e.toString())
          .join(' ');
    }

    return value.toString();
  }

  static double _parseAmountFromJson(dynamic value) {
    if (value is int) return value / 100;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }

  factory RecurrentExpense.fromMap(Map<String, dynamic> map) {
    return RecurrentExpense(
      id: map['id'],
      coupleId: map['couple_id'],
      createdBy: map['created_by'] ?? '',
      name: map['name'],
      amount: (map['amount'] as num).toDouble() / 100,
      recurrentInfo: _parseRecurrentInfo(map['recurrent_info']),
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
      'created_by': createdBy,
      'name': name,
      'amount': amount,
      'recurrent_info': recurrentInfo,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus.value,
    };
  }

  factory RecurrentExpense.fromJson(Map<String, dynamic> json) {
    return RecurrentExpense(
      id: json['id'],
      coupleId: json['couple_id'],
      createdBy: json['created_by'] ?? '',
      name: json['name'],
      amount: _parseAmountFromJson(json['amount']),
      recurrentInfo: _parseRecurrentInfo(json['recurrent_info']),
      createdAt: DateTime.parse(json['created_at']),
      syncStatus: SyncStatus.fromString(
        (json['sync_status'] as String? ?? 'pending').toUpperCase(),
      ),
    );
  }
}
