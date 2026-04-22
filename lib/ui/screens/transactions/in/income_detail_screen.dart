import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:pocket_union/ui/screens/transactions/in/widgets/new_entry_form.dart';

import '../../../../core/providers/providers.dart';

class IncomeDetailScreen extends ConsumerWidget {
  const IncomeDetailScreen({super.key, required this.incomeId});

  final String incomeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(incomeByIdProvider(incomeId));
    final categoriesAsync = ref.watch(incomeCategoriesForTransactionProvider);

    if (incomeAsync.isLoading || categoriesAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (incomeAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar ingreso')),
        body: Center(
          child: Text('Error al cargar ingreso: ${incomeAsync.error}'),
        ),
      );
    }

    if (categoriesAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar ingreso')),
        body: Center(
          child: Text('Error al cargar categorías: ${categoriesAsync.error}'),
        ),
      );
    }

    final income = incomeAsync.value;
    if (income == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar ingreso')),
        body: const Center(child: Text('No se encontró el ingreso.')),
      );
    }

    final categories = categoriesAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Editar ingreso')),
      body: SingleChildScrollView(
        child: NewEntryForm(
          categories: categories,
          initialIncome: income,
          onSubmit: (NewIncomeDto dto) async {
            final service = await ref.read(incomeServiceProvider.future);
            final success = await service.updateIncome(incomeId, dto);
            if (!context.mounted) return success;

            if (success) {
              ref.invalidate(incomeByIdProvider(incomeId));
              ref.invalidate(allIncomesProvider);
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo actualizar el ingreso'),
                ),
              );
            }
            return success;
          },
        ),
      ),
    );
  }
}
