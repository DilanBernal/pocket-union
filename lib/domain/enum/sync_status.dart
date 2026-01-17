enum SyncStatus {
  pending('PENDING'),
  synced('SYNCED'),
  conflict('CONFLICT'),
  deleted('DELETED');

  final String value;

  const SyncStatus(this.value);

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncStatus.pending,
    );
  }
}
