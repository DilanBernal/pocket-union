import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/auth_service_provider.dart';
import 'package:pocket_union/ui/screens/transactions/exp/widgets/new_expense_form.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';

class NewOutScreen extends ConsumerWidget {
  const NewOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoriesForTransactionProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error al cargar categorías: $err'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(expenseCategoriesCacheProvider.notifier).state = null;
                ref.invalidate(expenseCategoriesProvider);
                ref.invalidate(expenseCategoriesForTransactionProvider);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (categories) => SingleChildScrollView(
        child: Column(
          children: [
            const FormTitle(title: "Agregar salida de dinero"),
            NewExpenseForm(categories: categories),
          ],
        ),
      ),
    );
  }
}
