import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/dto/new_expense_dto.dart';
import 'package:pocket_union/ui/screens/transactions/exp/widgets/new_expense_form.dart';

import '../../../../core/providers/providers.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseByIdProvider(expenseId));
    final categoriesAsync = ref.watch(expenseCategoriesForTransactionProvider);

    if (expenseAsync.isLoading || categoriesAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (expenseAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar gasto')),
        body: Center(
          child: Text('Error al cargar gasto: ${expenseAsync.error}'),
        ),
      );
    }

    if (categoriesAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar gasto')),
        body: Center(
          child: Text('Error al cargar categorías: ${categoriesAsync.error}'),
        ),
      );
    }

    final expense = expenseAsync.value;
    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar gasto')),
        body: const Center(child: Text('No se encontró el gasto.')),
      );
    }

    final categories = categoriesAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Editar gasto')),
      body: SingleChildScrollView(
        child: NewExpenseForm(
          categories: categories,
          initialExpense: expense,
          onSubmit: (NewExpenseDto dto) async {
            final service = await ref.read(expenseServiceProvider.future);
            final success = await service.updateExpense(expenseId, dto);
            if (!context.mounted) return success;

            if (success) {
              ref.invalidate(expenseByIdProvider(expenseId));
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo actualizar el gasto')),
              );
            }
            return success;
          },
        ),
      ),
    );
  }
}
