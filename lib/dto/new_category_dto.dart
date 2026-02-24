import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';

class NewCategoryDto {
  final String name;
  String? coupleId;
  String? icon;
  String? shortDescription;
  String? color;
  CategoryHost host;

  NewCategoryDto({
    required this.name,
    required this.host,
    this.coupleId,
    this.icon,
    this.shortDescription,
    this.color,
  });

  static Category toCategoryDomain(NewCategoryDto dto, String id,
      {bool isSync = false}) {
    var status = isSync ? SyncStatus.pending : SyncStatus.synced;
    return Category(
        id: id,
        coupleId: dto.coupleId ?? '',
        name: dto.name,
        createdAt: DateTime.now(),
        categoryHost: dto.host,
        icon: dto.icon,
        shortDescription: dto.shortDescription,
        color: dto.color,
        syncStatus: status);
  }
}
