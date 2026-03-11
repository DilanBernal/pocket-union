class ExpenseFilterDto {
  final String? id;
  final String? coupleId;
  final String? categoryId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool? isFixed;

  ExpenseFilterDto({
    this.id,
    this.coupleId,
    this.categoryId,
    this.dateFrom,
    this.dateTo,
    this.isFixed,
  });
}
