import 'package:pocket_union/core/common/sync_entity_base.dart';
import 'package:pocket_union/core/enums/sync_status.dart';

class IncomeEntity extends OfflineBaseEntity {
  final String id;
  final String coupleId;
  final double amount;
  String? description;
  DateTime transactionDate;
  final DateTime createdAt;
  String name;
  final String? userRecipientId;
  final String categoryId;
  final String createdBy;
  bool isReceived;

  IncomeEntity({
    required this.id,
    required this.coupleId,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.name,
    this.userRecipientId,
    required this.categoryId,
    required this.createdBy,
    required this.isReceived,
    super.syncStatus = SyncStatus.pendingCreate,
    super.lastSyncedAt,
    super.localDeletedAt,
    DateTime? localUpdatedAt,
  }) : super(localUpdatedAt: localUpdatedAt ?? DateTime.now());
}
