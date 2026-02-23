class NewIncomeDto {
  final String name;
  final double amount;
  final String categoryId;
  final bool isReceived;
  final String userId;
  String? description;
  String? coupleId;
  final bool isRecurring;

  NewIncomeDto({
    required this.amount,
    required this.name,
    required this.categoryId,
    required this.isReceived,
    required this.userId,
    this.description,
    this.coupleId,
    this.isRecurring = false,
  });
}
