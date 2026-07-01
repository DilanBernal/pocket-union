import 'package:pocket_union/core/common/sync_entity_base.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';

class CategoryEntity extends OfflineBaseEntity {
  final String id;

  final String coupleId;

  final String name;

  final String? icon;

  final String? shortDescription;

  final String? color;

  final DateTime createdAt;

  final CategoryHost categoryHost;

  const CategoryEntity({
    required this.id,
    required this.coupleId,
    required this.name,
    this.icon,
    this.shortDescription,
    this.color,
    required this.createdAt,
    required this.categoryHost,
    required super.syncStatus,
    required super.localUpdatedAt,
    super.lastSyncedAt,
    super.localDeletedAt,
  });
}
