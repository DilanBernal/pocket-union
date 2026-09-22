import 'package:pocket_union/core/enums/sync_status.dart';

abstract class OfflineBaseEntity {
  /// Estado de sincronización con el servidor.
  SyncStatus syncStatus;

  /// Última vez que el servidor confirmó esta entidad.
  DateTime? lastSyncedAt;

  /// Última modificación realizada localmente.
  DateTime localUpdatedAt;

  /// Marca de borrado lógico.
  DateTime? localDeletedAt;

  OfflineBaseEntity({
    required this.syncStatus,
    required this.localUpdatedAt,
    this.lastSyncedAt,
    this.localDeletedAt,
  });

  /// Indica si la entidad fue eliminada localmente.
  bool get isDeleted => localDeletedAt != null;

  /// Indica si tiene cambios pendientes.
  bool get hasPendingChanges => syncStatus != SyncStatus.synced;
}
