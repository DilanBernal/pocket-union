import 'package:flutter/material.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/ui/screens/transactions/widgets/transaction_icon_utils.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem({
    super.key,
    required this.expense,
    required this.categoryById,
    required this.onTap,
  });

  final Expense expense;
  final Map<String, Category> categoryById;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryIcon = resolveTransactionIcon(
      categoryIds: expense.categoryIds,
      categoryById: categoryById,
    );
    final accentColor = resolveTransactionColor(
      categoryIds: expense.categoryIds,
      categoryById: categoryById,
      fallback: Colors.red,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Theme.of(context).chipTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor, width: 0.8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withValues(alpha: 0.15),
                  child: Icon(categoryIcon, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expense.description?.isNotEmpty == true
                            ? expense.description!
                            : 'Sin descripción',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expense.transactionDate?.toLocal()}'.split(' ')[0],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
