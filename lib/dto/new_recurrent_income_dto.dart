class NewRecurrentIncomeDto {
  final String name;
  final double amount;
  final String coupleId;
  final String createdBy;
  final String? userRecipientId;
  final String? recurrentInfo;

  NewRecurrentIncomeDto({
    required this.name,
    required this.amount,
    required this.coupleId,
    required this.createdBy,
    this.userRecipientId,
    this.recurrentInfo,
  });
}
