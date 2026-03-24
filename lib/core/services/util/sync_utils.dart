/// Servicio de utilidades para sincronización cloud ↔ local.
class SyncUtils {
  /// Compara dos listas de entidades por ID y devuelve
  /// los elementos que existen en cloud pero faltan en local.
  static List<T> findMissingInLocal<T>({
    required List<T> localItems,
    required List<T> cloudItems,
    required String Function(T) getId,
  }) {
    final localIds = localItems.map(getId).toSet();
    return cloudItems.where((item) => !localIds.contains(getId(item))).toList();
  }
}
