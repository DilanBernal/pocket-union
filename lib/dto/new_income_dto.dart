class NewIncomeDto {
  final String name;
  final double amount;
  final int importanceLevel;
  String? description;
  final String categoryId;
  final bool isRecurring;
  Object? recurrenceInterval;
  final bool isReceived;
  Object? receivedIn;

  NewIncomeDto({
    required this.amount,
    required this.name,
    required this.importanceLevel,
    required this.categoryId,
    required this.isRecurring,
    required this.isReceived,
    this.description,
    this.recurrenceInterval,
    this.receivedIn,
  });
}
