import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class EmptyTransactions extends StatelessWidget {
  const EmptyTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(TablerIcons.receipt, size: 32),
            SizedBox(height: 8),
            Text('Todavia no hay transacciones', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
