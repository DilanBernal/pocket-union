enum CoupleUsableState {
  waiting('WAITING'),
  ready('READY'),
  canceled('CANCELED');

  final String value;

  const CoupleUsableState(this.value);

  static CoupleUsableState fromString(String value) {
    return CoupleUsableState.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => CoupleUsableState.waiting,
    );
  }
}
