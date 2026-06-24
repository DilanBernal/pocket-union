import 'package:drift/drift.dart';

import '../../../domain/enum/category_host.dart';
import '../../../domain/enum/sync_status.dart';
import '../../../domain/models/category.dart';
import '../app_database.dart' as drift;

class CategoryMapper {
  Category toDomain(drift.Category data) {
    return Category(
      id: data.id,
      coupleId: data.coupleId,
      name: data.name,
      icon: data.icon,
      shortDescription: data.shortDescription,
      color: data.color,
      createdAt: data.createdAt,
      categoryHost: CategoryHost.fromString(data.categoryHost),
      syncStatus: SyncStatus.fromString(
        (data.syncStatus).toUpperCase(),
      ),
      lastSyncAt: null,
      localUpdatedAt: data.localUpdatedAt,
    );
  }

  drift.CategoriesCompanion toCompanion(Category category) {
    return drift.CategoriesCompanion.insert(
      id: category.id,
      name: category.name,
      coupleId: category.coupleId,
      icon: Value(category.icon),
      shortDescription: Value(category.shortDescription),
      color: Value(category.color),
      categoryHost: category.categoryHost.value,
      createdAt: Value(category.createdAt),
      syncStatus: Value(category.syncStatus.value.toLowerCase()),
      localUpdatedAt: Value(category.localUpdatedAt),
      isDeleted: const Value(false),
    );
  }
}
