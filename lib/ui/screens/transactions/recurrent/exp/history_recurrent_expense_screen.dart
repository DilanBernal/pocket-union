import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocket_union/core/providers/auth_service_provider.dart';
import 'package:pocket_union/ui/router.dart';

class HistoryRecurrentExpenseScreen extends ConsumerWidget {
  const HistoryRecurrentExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurrentExpensesAsync = ref.watch(allRecurrentExpensesProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: '4 ',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos programados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allRecurrentExpensesProvider);
        },
        child: recurrentExpensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error al cargar gastos programados: $error'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 140),
                  const Icon(Icons.event_repeat, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No hay gastos programados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Aqui veras los gastos con ejecucion recurrente.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.newRecurrentExpense),
                      icon: const Icon(Icons.add),
                      label: const Text('Programar gasto'),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.trending_down),
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      'recurrent_info: ${item.recurrentInfo ?? '* * * * *'}',
                    ),
                    trailing: Text(
                      currencyFormat.format(item.amount),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
