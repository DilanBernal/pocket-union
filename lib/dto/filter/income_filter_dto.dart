class IncomeFilterDto {
  final String? id;
  final String? coupleId;
  final String? categoryId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool? isRecurring;

  IncomeFilterDto({
    this.id,
    this.coupleId,
    this.categoryId,
    this.dateFrom,
    this.dateTo,
    this.isRecurring,
  });
}
