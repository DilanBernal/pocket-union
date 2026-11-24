import 'package:pocket_union/core/common/sync_entity_base.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';

class ExpenseEntity extends OfflineBaseEntity {
  final String id;
  final String coupleId;
  String name;
  final String createdBy;
  DateTime? transactionDate;
  String? description;
  final double amount;
  List<String> categoryIds;
  List<CategoryEntity> categories = [];
  final bool isFixed;
  final int importanceLevel;
  final bool isPlaned;
  final DateTime createdAt;
  bool isPaid;

  ExpenseEntity({
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
    super.syncStatus = SyncStatus.pendingCreate,
    super.lastSyncedAt,
    DateTime? localUpdatedAt,
    this.isPaid = true,
  }) : super(localUpdatedAt: localUpdatedAt ?? DateTime.now());
}
