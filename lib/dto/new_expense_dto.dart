class NewExpenseDto {
  final double amount;
  final String name;
  final int importanceLevel;
  String? description;
  final List<String> categoryIds;
  final bool isFixed;
  final bool isPlaned;
  String? coupleId;
  String? createdBy;
  DateTime? transactionDate;

  NewExpenseDto({
    required this.amount,
    required this.name,
    this.importanceLevel = 0,
    required this.categoryIds,
    this.isFixed = false,
    this.isPlaned = false,
    this.description,
    this.coupleId,
    this.createdBy,
    this.transactionDate,
  });
}
