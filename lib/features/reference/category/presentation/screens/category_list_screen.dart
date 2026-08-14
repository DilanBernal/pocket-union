import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pocket_union/core/utils/categories_list_provider.dart';
import 'package:pocket_union/core/utils/color_parser.dart';
import 'package:pocket_union/features/reference/application/services/category_service.dart';
import 'package:pocket_union/features/reference/category/presentation/widgets/category_list_item.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/ui/router.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  final Set<String> _hiddenCategoryIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesListProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(255, 48, 24, 77), Color(0xFF1A1026)],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Categorías')),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.pushNamed(context, AppRoutes.newCategory);
            ref.invalidate(allCategoriesListProvider);
          },
          child: const Icon(TablerIcons.plus),
        ),

        body: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error al cargar: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (categories) {
            final visibleCategories = categories
                .where((category) => !_hiddenCategoryIds.contains(category.id))
                .toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(allCategoriesListProvider);
                await ref.read(allCategoriesListProvider.future);
              },
              child: visibleCategories.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'No hay categorías. ¡Crea una!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: visibleCategories.length,
                      itemBuilder: (context, index) {
                        final category = visibleCategories[index];
                        return _CategoryListTile(
                          category: category,
                          onDismissed: () {
                            setState(() {
                              _hiddenCategoryIds.add(category.id);
                            });
                          },
                          onDismissFailed: () {
                            if (!mounted) return;
                            setState(() {
                              _hiddenCategoryIds.remove(category.id);
                            });
                          },
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

// Widget extraído para mantener el árbol de widgets limpio y optimizar el renderizado
class _CategoryListTile extends ConsumerWidget {
  final CategoryEntity category;
  final VoidCallback onDismissed;
  final VoidCallback onDismissFailed;

  const _CategoryListTile({
    required this.category,
    required this.onDismissed,
    required this.onDismissFailed,
  });

  Future<void> _handleDeleteCategory(WidgetRef ref) async {
    final service = await ref.read(categoryServiceProvider.future);
    await service.deleteCategory(category.id);
    ref.invalidate(allCategoriesListProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.editCategory,
            arguments: category.id,
          );
          ref.invalidate(allCategoriesListProvider);
        },
        child: Dismissible(
          key: Key(category.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar categoría'),
                content: Text('¿Estás seguro de eliminar "${category.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) async {
            onDismissed();
            try {
              await _handleDeleteCategory(ref);
            } catch (e) {
              onDismissFailed();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo eliminar la categoría'),
                  ),
                );
              }
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 8),
                Text('Eliminar', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          child: Hero(
            tag: 'category_item_${category.id}',
            child: CategoryListItem(
              categoryName: category.name,
              selectedColor: parseColorFromHex(
                category.color,
                fallback: Colors.grey,
              ),
              selectedIcon: IconData(
                int.parse(category.icon!),
                fontFamily: 'tabler-icons',
                fontPackage: 'flutter_tabler_icons',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
