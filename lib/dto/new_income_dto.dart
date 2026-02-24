class NewIncomeDto {
  final String name;
  final double amount;
  String? description;
  final String categoryId;
  final bool isRecurring;
  Object? recurrenceInterval;
  final bool isReceived;
  Object? receivedIn;
  String? coupleId;

  /// null = NOSOTROS (ambos), valor = YO (solo ese usuario)
  String? userId;

  NewIncomeDto({
    required this.amount,
    required this.name,
    required this.categoryId,
    required this.isRecurring,
    required this.isReceived,
    this.description,
    this.recurrenceInterval,
    this.receivedIn,
    this.coupleId,
    this.userId,
  });
}
