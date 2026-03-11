class NewRecurrentIncomeDto {
  final String name;
  final double amount;
  final String coupleId;
  final String? userRecipientId;
  final List<int>? recurrentInfo;

  NewRecurrentIncomeDto({
    required this.name,
    required this.amount,
    required this.coupleId,
    this.userRecipientId,
    this.recurrentInfo,
  });
}
