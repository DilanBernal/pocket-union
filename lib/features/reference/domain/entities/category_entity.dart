import 'package:pocket_union/core/common/sync_entity_base.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
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

  CategoryEntity({
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'icon': icon,
      'short_description': shortDescription,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'category_host': categoryHost.name.toUpperCase(),
    };
  }

  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map['id'],
      coupleId: map['couple_id'] ?? map['coupleId'],
      name: map['name'],
      icon: map['icon'],
      shortDescription: map['short_description'],
      color: map['color'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.parse(map['createdAt']),
      categoryHost: map['category_host'] is int
          ? CategoryHost.values[map['category_host']]
          : CategoryHost.values.firstWhere(
              (e) => e.name.toUpperCase() == (map['category_host']),
            ),
      syncStatus: map['sync_status'] is int
          ? SyncStatus.values[map['sync_status']]
          : SyncStatus.values.firstWhere(
              (e) =>
                  e.name.toLowerCase() ==
                  (map['sync_status'] ??
                      SyncStatus.pendingCreate.name.toLowerCase()),
            ),
      localUpdatedAt: map['local_updated_at'] != null
          ? DateTime.parse(map['local_updated_at'])
          : DateTime.now().toUtc(),
      lastSyncedAt: (map['last_synced_at']) != null
          ? DateTime.parse((map['last_synced_at']))
          : null,
      localDeletedAt: (map['local_deleted_at']) != null
          ? DateTime.parse((map['local_deleted_at']))
          : null,
    );
  }
}
