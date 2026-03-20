import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/ui/screens/transactions/exp/widgets/expense_item.dart';

class HistoryExpensesScreen extends ConsumerStatefulWidget {
  const HistoryExpensesScreen({super.key});

  @override
  ConsumerState<HistoryExpensesScreen> createState() =>
      _HistoryExpensesScreenState();
}

class _HistoryExpensesScreenState extends ConsumerState<HistoryExpensesScreen> {
  Future<List<Expense>> _loadExpenses() async {
    final expenseService = await ref.watch(expenseServiceProvider.future);
    return expenseService.getAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de gastos'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadExpenses();
          });
        },
        child: FutureBuilder<List<Expense>>(
          future: _loadExpenses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error al cargar gastos: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay gastos registrados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aquí verás todos tus gastos registrados.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              prototypeItem: SizedBox(
                height: 80,
              ), // Mejora el rendimiento con items de tamaño fijo
              itemBuilder: (context, index) {
                final expense = snapshot.data![index];
                return ExpenseItem(expense: expense);
              },
            );
          },
        ),
      ),
    );
  }
}
