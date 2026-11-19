class CoupleBalanceEntity {
  final String coupleId;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const CoupleBalanceEntity({
    required this.coupleId,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  const CoupleBalanceEntity.zero({required this.coupleId})
    : totalIncome = 0,
      totalExpense = 0,
      balance = 0;

  factory CoupleBalanceEntity.fromMap(Map<String, dynamic> map) {
    return CoupleBalanceEntity(
      coupleId: map['couple_id']?.toString() ?? '',
      totalIncome: (map['total_income'] as num? ?? 0).toDouble(),
      totalExpense: (map['total_expense'] as num? ?? 0).toDouble(),
      balance: (map['balance'] as num? ?? 0).toDouble(),
    );
  }
}
