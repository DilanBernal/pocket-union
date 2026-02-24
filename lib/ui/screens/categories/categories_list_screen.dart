import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart' as domain;
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/ui/router.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Categorías'),
        backgroundColor: const Color.fromRGBO(46, 0, 76, 0.75),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.newCategory);
          ref.invalidate(allCategoriesProvider);
          ref.invalidate(incomeCategoriesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
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
                onPressed: () => ref.invalidate(allCategoriesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay categorías creadas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, AppRoutes.newCategory);
                      ref.invalidate(allCategoriesProvider);
                      ref.invalidate(incomeCategoriesProvider);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera categoría'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // await Navigator.pushNamed(context, AppRoutes.newCategory);
                      ref.invalidate(allCategoriesProvider);
                      ref.invalidate(incomeCategoriesProvider);
                      final service =
                          await ref.watch(categoryServiceProvider.future);
                      await _createDefaultCategories(service);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear categorías por defecto'),
                  ),
                ],
              ),
            );
          }

          // Separar por host
          final incomeCategories = categories
              .where((c) => c.categoryHost == CategoryHost.income)
              .toList();
          final expenseCategories = categories
              .where((c) => c.categoryHost == CategoryHost.expense)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allCategoriesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (incomeCategories.isNotEmpty) ...[
                  _buildSectionHeader(
                      context, 'Ingresos', Icons.arrow_downward, Colors.green),
                  ...incomeCategories.map((c) => _buildCategoryTile(c)),
                ],
                if (expenseCategories.isNotEmpty) ...[
                  _buildSectionHeader(
                      context, 'Gastos', Icons.arrow_upward, Colors.red),
                  ...expenseCategories.map((c) => _buildCategoryTile(c)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(domain.Category category) {
    final iconData = category.icon != null
        ? IconData(int.parse(category.icon!), fontFamily: 'MaterialIcons')
        : Icons.category;

    final color = category.color != null
        ? Color(int.parse(category.color!.replaceFirst('#', ''), radix: 16))
        : Colors.grey;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(30),
        child: Icon(iconData, color: color),
      ),
      title: Text(category.name),
      subtitle: category.shortDescription != null &&
              category.shortDescription!.isNotEmpty
          ? Text(
              category.shortDescription!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: _buildSyncBadge(category.syncStatus.value),
    );
  }

  Widget _buildSyncBadge(String syncStatus) {
    final IconData icon;
    final Color color;

    switch (syncStatus) {
      case 'SYNCED':
        icon = Icons.cloud_done;
        color = Colors.green;
      case 'PENDING':
        icon = Icons.cloud_upload_outlined;
        color = Colors.orange;
      case 'CONFLICT':
        icon = Icons.warning_amber;
        color = Colors.red;
      default:
        icon = Icons.cloud_off;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }

  Future<void> _createDefaultCategories(CategoryPort categoryService) async {
    try {
      await categoryService.createDefaultCategories("");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
