class IncomeInsDto {
  final String name;
  final String? description;
  final double? amount;
  final List<String>? categoryIds;
  final String? primaryCategoryId;
  final DateTime? date;
  final int? recipient;

  IncomeInsDto({
    required this.name,
    this.description,
    this.amount,
    this.categoryIds,
    this.date,
    this.primaryCategoryId,
    this.recipient,
  });
}
