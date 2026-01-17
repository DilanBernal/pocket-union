class NewExpenseDto {
  final double amount;
  final String name;
  final int importanceLevel;
  String? description;
  final String categoryId;
  final bool isFixed;
  final bool isPlaned;

  NewExpenseDto({
    required this.amount,
    required this.name,
    required this.importanceLevel,
    required this.categoryId,
    required this.isFixed,
    required this.isPlaned,
    this.description,
  });
}
