import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:pocket_union/features/transaction/application/services/expense_service.dart';
import 'package:pocket_union/features/transaction/domain/entities/expense_entity.dart';
import 'package:pocket_union/features/transaction/expense/presentation/controllers/expense_history.controller.dart';

class ExpenseHistoryList extends ConsumerWidget {
  const ExpenseHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de gastos')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(expenseHistoryControllerProvider.notifier).refresh(),
        child: expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: Center(
                  child: Text(
                    'No se pudo cargar el historial: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          data: (expenses) => expenses.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 220),
                    Icon(TablerIcons.receipt_off, size: 48),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        'No hay gastos registrados',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) =>
                      _ExpenseHistoryTile(expense: expenses[index]),
                ),
        ),
      ),
    );
  }
}

class _ExpenseHistoryTile extends StatelessWidget {
  final ExpenseEntity expense;

  const _ExpenseHistoryTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'es');
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Eliminar gasto'),
          content: Text('¿Deseas eliminar "${expense.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        final container = ProviderScope.containerOf(context);
        final service = await container.read(expenseServiceProvider.future);
        await service.deleteExpense(expense.id);
        container.invalidate(expenseHistoryControllerProvider);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color.fromRGBO(
              205,
              70,
              70,
              1,
            ).withValues(alpha: 0.12),
            child: const Icon(
              TablerIcons.arrow_down,
              color: Color.fromRGBO(205, 70, 70, 1),
            ),
          ),
          title: Text(
            expense.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            expense.description?.isNotEmpty == true
                ? '${dateFormat.format(expense.transactionDate ?? DateTime.now())} · ${expense.description}'
                : dateFormat.format(expense.transactionDate ?? DateTime.now()),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${currencyFormat.format(expense.amount)}',
                style: const TextStyle(
                  color: Color.fromRGBO(205, 70, 70, 1),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!expense.isPaid)
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
      ),
    );
  }
}
