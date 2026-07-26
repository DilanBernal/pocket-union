import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';

class CategoryUpdDto {
  final String id;
  final String name;
  String? icon;
  String? shortDescription;
  String? color;
  CategoryHost host;

  CategoryUpdDto({
    required this.id,
    required this.name,
    required this.host,
    this.icon,
    this.shortDescription,
    this.color,
  });

  static CategoryEntity toCategoryDomain(
    CategoryUpdDto dto,
    String id, {
    bool isSync = false,
  }) {
    var status = !isSync ? SyncStatus.pendingCreate : SyncStatus.synced;
    return CategoryEntity(
      id: id,
      coupleId: '',
      name: dto.name,
      createdAt: DateTime.now(),
      categoryHost: dto.host,
      icon: dto.icon,
      shortDescription: dto.shortDescription,
      color: dto.color,
      syncStatus: status,
      localUpdatedAt: DateTime.now().toUtc(),
    );
  }
}
