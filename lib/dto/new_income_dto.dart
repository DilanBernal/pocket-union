class NewIncomeDto {
  final String name;
  final double amount;
  String? description;
  final List<String> categoryIds;
  final bool isRecurring;
  final bool isReceived;
  Object? receivedIn;
  String? coupleId;
  DateTime? transactionDate;

  /// null = NOSOTROS (ambos), valor = YO (solo ese usuario)
  String? userId;

  NewIncomeDto({
    required this.amount,
    required this.name,
    required this.categoryIds,
    required this.isRecurring,
    required this.isReceived,
    this.description,
    this.receivedIn,
    this.coupleId,
    this.userId,
    this.transactionDate,
  });
}
