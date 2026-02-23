enum SyncStatus {
  pending('pending'),
  synced('synced'),
  conflict('conflict'),
  deleted('deleted');

  final String value;

  const SyncStatus(this.value);

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => SyncStatus.pending,
    );
  }
}
