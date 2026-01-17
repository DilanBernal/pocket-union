enum CoupleUsableState {
  waiting('WAITING'),
  active('ACTIVE'),
  inactive('INACTIVE');

  final String value;

  const CoupleUsableState(this.value);

  static CoupleUsableState fromString(String value) {
    return CoupleUsableState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CoupleUsableState.waiting,
    );
  }
}
