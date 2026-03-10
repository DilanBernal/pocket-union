import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';

class CategoryFilterDto {
  final String? id;
  final String? coupleId;
  final CategoryHost? host;
  final SyncStatus? syncStatus;

  CategoryFilterDto({this.id, this.coupleId, this.host, this.syncStatus});
}
