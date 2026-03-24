class NewRecurrentExpenseDto {
  final String name;
  final double amount;
  final String coupleId;
  final String? createdBy;
  final String? recurrentInfo;

  NewRecurrentExpenseDto({
    required this.name,
    required this.amount,
    required this.coupleId,
    this.createdBy,
    this.recurrentInfo,
  });
}
