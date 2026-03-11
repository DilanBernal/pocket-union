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

  NewExpenseDto({
    required this.amount,
    required this.name,
    required this.importanceLevel,
    required this.categoryIds,
    required this.isFixed,
    required this.isPlaned,
    this.description,
    this.coupleId,
    this.createdBy,
  });
}
