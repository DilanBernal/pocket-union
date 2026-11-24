enum CoupleTransactionType { income, expense }

class CoupleTransactionEntity {
  final String id;
  final String coupleId;
  final CoupleTransactionType type;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final String? createdBy;
  final String name;
  final bool isPaid;

  const CoupleTransactionEntity({
    required this.id,
    required this.coupleId,
    required this.type,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.createdBy,
    required this.name,
    required this.isPaid,
  });

  factory CoupleTransactionEntity.fromMap(Map<String, dynamic> map) {
    final rawType = map['type']?.toString().toLowerCase();
    final rawDate = map['transaction_date']?.toString();

    return CoupleTransactionEntity(
      id: map['id']?.toString() ?? '',
      coupleId: map['couple_id']?.toString() ?? '',
      type: rawType == 'expense'
          ? CoupleTransactionType.expense
          : CoupleTransactionType.income,
      amount: (map['amount'] as num? ?? 0).toDouble(),
      description: map['description']?.toString(),
      transactionDate: rawDate != null
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : DateTime.now(),
      createdBy: map['created_by']?.toString(),
      name: map['name']?.toString() ?? '',
      isPaid: map['is_paid'] == true,
    );
  }
}
