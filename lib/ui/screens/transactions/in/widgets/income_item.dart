import 'package:flutter/material.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/ui/screens/transactions/widgets/transaction_icon_utils.dart';

class IncomeItem extends StatelessWidget {
  const IncomeItem({
    super.key,
    required this.income,
    required this.categoryById,
    required this.onTap,
  });

  final Income income;
  final Map<String, Category> categoryById;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryIcon = resolveTransactionIcon(
      categoryIds: income.categoryIds,
      categoryById: categoryById,
    );
    final accentColor = resolveTransactionColor(
      categoryIds: income.categoryIds,
      categoryById: categoryById,
      fallback: Colors.green,
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
                        income.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        income.description?.isNotEmpty == true
                            ? income.description!
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
                      '\$${income.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${income.transactionDate.toLocal()}'.split(' ')[0],
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
