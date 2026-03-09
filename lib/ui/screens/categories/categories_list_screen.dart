import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart' as domain;
import 'package:pocket_union/ui/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() =>
      _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {
  bool _isCreatingDefaults = false;
  bool _isSyncingAll = false;
  final Set<String> _syncingIds = {};

  Future<void> _navigateToNewCategory() async {
    await Navigator.pushNamed(context, AppRoutes.newCategory);
    ref.invalidate(allCategoriesProvider);
    ref.invalidate(incomeCategoriesProvider);
  }

  Future<void> _createDefaultCategories() async {
    setState(() => _isCreatingDefaults = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final coupleId = prefs.getString('coupleId') ?? '';

      try {
        final service = await ref.read(categoryServiceProvider.future);
        await service.createDefaultCategories(coupleId);
      } catch (_) {
        final dao = ref.read(categoryDaoProvider);
        await dao.createDefaultCategories(coupleId);
      }

      ref.invalidate(allCategoriesProvider);
      ref.invalidate(incomeCategoriesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categorías por defecto creadas exitosamente'),
          backgroundColor: Colors.green,
          duration: Durations.extralong4,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear categorías: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreatingDefaults = false);
    }
  }

  Future<void> _syncSingleCategory(String categoryId) async {
    if (_syncingIds.contains(categoryId)) return;
    setState(() => _syncingIds.add(categoryId));

    try {
      final service = await ref.read(categoryServiceProvider.future);
      final success = await service.syncCategory(categoryId);

      ref.invalidate(allCategoriesProvider);
      ref.invalidate(incomeCategoriesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Categoría sincronizada exitosamente'
                : 'Error al sincronizar. Se marcó como conflicto.',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _syncingIds.remove(categoryId));
    }
  }

  Future<void> _syncAllCategories() async {
    setState(() => _isSyncingAll = true);

    try {
      final service = await ref.read(categoryServiceProvider.future);
      final results = await service.syncAllCategories();

      ref.invalidate(allCategoriesProvider);
      ref.invalidate(incomeCategoriesProvider);

      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las categorías ya están sincronizadas'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final successCount = results.values.where((v) => v).length;
      final failCount = results.values.where((v) => !v).length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failCount == 0
                ? '$successCount categoría(s) sincronizada(s) exitosamente'
                : '$successCount sincronizada(s), $failCount con conflicto',
          ),
          backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Categorías'),
        backgroundColor: const Color.fromRGBO(46, 0, 76, 0.75),
        actions: [
          IconButton(
            onPressed: _isSyncingAll ? null : _syncAllCategories,
            icon: _isSyncingAll
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_sync),
            tooltip: 'Sincronizar todas las categorías',
          ),
          IconButton(
            onPressed: _isCreatingDefaults ? null : _createDefaultCategories,
            icon: _isCreatingDefaults
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.playlist_add),
            tooltip: 'Crear categorías por defecto',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewCategory,
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
                  const Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay categorías creadas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _navigateToNewCategory,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera categoría'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isCreatingDefaults
                        ? null
                        : _createDefaultCategories,
                    icon: _isCreatingDefaults
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.playlist_add),
                    label: Text(
                      _isCreatingDefaults
                          ? 'Creando...'
                          : 'Crear categorías por defecto',
                    ),
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
                    context,
                    'Ingresos',
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                  ...incomeCategories.map((c) => _buildCategoryTile(c)),
                ],
                if (expenseCategories.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Gastos',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
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
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
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
      subtitle:
          category.shortDescription != null &&
              category.shortDescription!.isNotEmpty
          ? Text(
              category.shortDescription!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: _buildSyncBadge(category),
    );
  }

  Widget _buildSyncBadge(domain.Category category) {
    final isSyncing = _syncingIds.contains(category.id);
    final syncStatus = category.syncStatus;

    if (isSyncing) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final IconData icon;
    final Color color;
    final bool isTappable;

    switch (syncStatus) {
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        isTappable = false;
      case SyncStatus.pending:
        icon = Icons.cloud_upload_outlined;
        color = Colors.orange;
        isTappable = true;
      case SyncStatus.conflict:
        icon = Icons.warning_amber;
        color = Colors.red;
        isTappable = true;
      case SyncStatus.deleted:
        icon = Icons.cloud_off;
        color = Colors.grey;
        isTappable = false;
    }

    if (isTappable) {
      return IconButton(
        onPressed: () => _syncSingleCategory(category.id),
        icon: Icon(icon, color: color, size: 20),
        tooltip: syncStatus == SyncStatus.conflict
            ? 'Reintentar sincronización'
            : 'Sincronizar',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return Icon(icon, color: color, size: 20);
  }
}
