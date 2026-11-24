class ExpenseInsDto {
  final String name;
  final double amount;
  final DateTime? transactionDate;
  final String? description;
  final List<String> categoryIds;
  final String? primaryCategoryId;
  final int importanceLevel;
  final bool isFixed;
  final bool isPlaned;
  final bool isPaid;
  final List<ExpenseShareDto> shares;

  const ExpenseInsDto({
    required this.name,
    required this.amount,
    this.transactionDate,
    this.description,
    this.categoryIds = const [],
    this.primaryCategoryId,
    this.importanceLevel = 1,
    this.isFixed = false,
    this.isPlaned = false,
    this.isPaid = true,
    this.shares = const [],
  });
}

class ExpenseShareDto {
  final String userId;
  final double sharePercentage;

  const ExpenseShareDto({required this.userId, required this.sharePercentage});
}
