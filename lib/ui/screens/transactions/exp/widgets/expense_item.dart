import 'package:flutter/material.dart';
import 'package:pocket_union/domain/models/expense.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).chipTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 2),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.3),
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: ListTile(
        leading: const Icon(Icons.attach_money),
        title: Text(expense.name),
        subtitle: Text('Monto: \$${expense.amount.toStringAsFixed(2)}'),
        trailing: Text('${expense.createdAt.toLocal()}'.split(' ')[0]),
      ),
    );
  }
}
