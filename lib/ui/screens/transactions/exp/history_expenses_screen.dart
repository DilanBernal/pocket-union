import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/ui/screens/transactions/exp/expense_detail_screen.dart';
import 'package:pocket_union/ui/screens/transactions/exp/widgets/expense_item.dart';

import '../../../../core/providers/providers.dart';

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

  Future<bool> _deleteExpense(String expenseId) async {
    final expenseService = await ref.read(expenseServiceProvider.future);
    final deleted = await expenseService.deleteExpense(expenseId);

    if (!mounted) return deleted;

    if (deleted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto eliminado')));
      setState(() {});
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo eliminar el gasto')),
    );
    return false;
  }

  Future<void> _openExpenseDetail(Expense expense) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(expenseId: expense.id),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesForTransactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de gastos'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expenseCategoriesForTransactionProvider);
          setState(() {});
        },
        child: FutureBuilder<List<Expense>>(
          future: _loadExpenses(),
          builder: (context, snapshot) {
            if (categoriesAsync.isLoading ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categoriesAsync.hasError) {
              return Center(
                child: Text(
                  'Error al cargar categorías: ${categoriesAsync.error}',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error al cargar gastos: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // const SizedBox(height: 160),
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  // const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No hay gastos registrados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Aqui veras todos tus gastos registrados.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(expenseCategoriesForTransactionProvider);
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar'),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              );
            }

            final categoryById = {
              for (final Category category in (categoriesAsync.value ?? []))
                category.id: category,
            };

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: snapshot.data?.length ?? 0,
              prototypeItem: const SizedBox(height: 85),
              itemBuilder: (context, index) {
                final expense = snapshot.data![index];
                return Dismissible(
                  key: ValueKey(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _deleteExpense(expense.id),
                  child: ExpenseItem(
                    expense: expense,
                    categoryById: categoryById,
                    onTap: () => _openExpenseDetail(expense),
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
