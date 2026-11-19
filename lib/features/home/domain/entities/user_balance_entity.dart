class UserBalanceEntity {
  final String userId;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const UserBalanceEntity({
    required this.userId,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  const UserBalanceEntity.zero({required this.userId})
    : totalIncome = 0,
      totalExpense = 0,
      balance = 0;

  factory UserBalanceEntity.fromMap(Map<String, dynamic> map) {
    return UserBalanceEntity(
      userId: map['user_id']?.toString() ?? '',
      totalIncome: (map['total_income'] as num? ?? 0).toDouble(),
      totalExpense: (map['total_expense'] as num? ?? 0).toDouble(),
      balance: (map['balance'] as num? ?? 0).toDouble(),
    );
  }
}
