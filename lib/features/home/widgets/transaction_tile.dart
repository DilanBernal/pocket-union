import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:pocket_union/features/home/domain/entities/couple_transaction_entity.dart';

class TransactionTile extends StatelessWidget {
  final CoupleTransactionEntity transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == CoupleTransactionType.expense;
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('d MMM yyyy', 'es');
    final amountPrefix = isExpense ? '-' : '+';
    final amountColor = isExpense
        ? const Color.fromRGBO(205, 70, 70, 1)
        : const Color.fromRGBO(53, 145, 94, 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.12),
          child: Icon(
            isExpense ? TablerIcons.arrow_down : TablerIcons.arrow_up,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.name.isEmpty
              ? (isExpense ? 'Gasto' : 'Ingreso')
              : transaction.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(dateFormat.format(transaction.transactionDate)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix${currencyFormat.format(transaction.amount)}',
              style: TextStyle(color: amountColor, fontWeight: FontWeight.w800),
            ),
            if (isExpense && !transaction.isPaid)
              const Text(
                'Pendiente',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
