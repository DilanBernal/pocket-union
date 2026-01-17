enum CategoryHost {
  expense('EXPENSE'),
  income('INCOME');

  final String value;

  const CategoryHost(this.value);

  static CategoryHost fromString(String value) {
    return CategoryHost.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CategoryHost.expense,
    );
  }
}
