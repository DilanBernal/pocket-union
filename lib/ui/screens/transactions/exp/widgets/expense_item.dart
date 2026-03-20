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
        border: Border.all(color: Colors.grey, width: 0.5),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.3),
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(),
            child: Padding(
              padding: EdgeInsetsGeometry.all(4),
              child: Icon(Icons.attach_money),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(expense.name),
              Text('Monto: \$${expense.amount.toStringAsFixed(2)}'),
            ],
          ),
          // expense.
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              maximumSize: Size(120, 40),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => (),
            child: Text('${expense.description}'),
          ),
        ],
      ),
      // ListTile(
      //   leading: const Icon(Icons.attach_money),
      //   title: Text(expense.name),
      //   subtitle: Text('Monto: \$${expense.amount.toStringAsFixed(2)}'),
      //   trailing: Text('${expense.createdAt.toLocal()}'.split(' ')[0]),
      // ),
    );
  }
}
