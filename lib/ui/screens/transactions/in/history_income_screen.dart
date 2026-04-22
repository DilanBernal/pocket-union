import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/ui/screens/transactions/in/income_detail_screen.dart';
import 'package:pocket_union/ui/screens/transactions/in/widgets/income_item.dart';

import '../../../../core/providers/providers.dart';

class HistoryIncomeScreen extends ConsumerWidget {
  const HistoryIncomeScreen({super.key});

  Future<bool> _deleteIncome(
    BuildContext context,
    WidgetRef ref,
    String incomeId,
  ) async {
    final incomeService = await ref.read(incomeServiceProvider.future);
    final deleted = await incomeService.deleteIncome(incomeId);
    if (!context.mounted) return deleted;

    if (deleted) {
      ref.invalidate(allIncomesProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingreso eliminado')));
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo eliminar el ingreso')),
    );
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(allIncomesProvider);
    final categoriesAsync = ref.watch(incomeCategoriesForTransactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de ingresos'),
        backgroundColor: const Color.fromRGBO(46, 0, 76, 0.75),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allIncomesProvider);
          ref.invalidate(incomeCategoriesForTransactionProvider);
        },
        child: incomesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Error al cargar ingresos: $error')),
          data: (incomes) {
            if (categoriesAsync.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categoriesAsync.hasError) {
              return Center(
                child: Text(
                  'Error al cargar categorias: ${categoriesAsync.error}',
                ),
              );
            }

            if (incomes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 160),
                  const Icon(Icons.trending_up, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No hay ingresos registrados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Aqui veras todos tus ingresos registrados.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(allIncomesProvider);
                        ref.invalidate(incomeCategoriesForTransactionProvider);
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
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                final income = incomes[index];
                return Dismissible(
                  key: ValueKey(income.id),
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
                  confirmDismiss: (_) => _deleteIncome(context, ref, income.id),
                  child: IncomeItem(
                    income: income,
                    categoryById: categoryById,
                    onTap: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) =>
                              IncomeDetailScreen(incomeId: income.id),
                        ),
                      );

                      if (updated == true) {
                        ref.invalidate(allIncomesProvider);
                      }
                    },
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
