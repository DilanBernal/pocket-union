import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/services/util/color_parser.dart';
import 'package:pocket_union/core/providers/auth_service_provider.dart';
import 'package:pocket_union/core/providers/data_cloud_providers.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart' as domain;
import 'package:pocket_union/dto/update_category_dto.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() =>
      _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen>
    with SingleTickerProviderStateMixin {
  bool _isCreatingDefaults = false;
  bool _isSyncingAll = false;
  final Set<String> _syncingIds = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNewCategory() async {
    await Navigator.pushNamed(context, AppRoutes.newCategory);
    ref.invalidate(allCategoriesProvider);
    ref.invalidate(incomeCategoriesProvider);
    ref.invalidate(expenseCategoriesProvider);
  }

  bool get _canShowDefaultsButton {
    final alreadyCreated = ref.read(defaultCategoriesCreatedProvider);
    return !alreadyCreated;
  }

  Future<void> _createDefaultCategories() async {
    setState(() => _isCreatingDefaults = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final coupleId = prefs.getString('coupleId') ?? '';

      final dao = ref.read(categoryDaoProvider);
      await dao.createDefaultCategories(coupleId);

      ref.read(defaultCategoriesCreatedProvider.notifier).state = true;
      ref.invalidate(allCategoriesProvider);
      ref.invalidate(incomeCategoriesProvider);
      ref.invalidate(expenseCategoriesProvider);

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
      ref.invalidate(expenseCategoriesProvider);

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
      ref.invalidate(expenseCategoriesProvider);

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

  void _showEditCategoryDialog(domain.Category category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(
      text: category.shortDescription ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editar categoría',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.label),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLength: 120,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  if (newName.isEmpty) return;

                  final dto = UpdateCategoryDto(
                    id: category.id,
                    name: newName,
                    shortDescription: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  );

                  try {
                    final service = await ref.read(
                      categoryServiceProvider.future,
                    );
                    await service.updateCategory(dto);
                  } catch (_) {
                    final dao = ref.read(categoryDaoProvider);
                    await dao.updateCategory(dto);
                  }

                  ref.invalidate(allCategoriesProvider);
                  ref.invalidate(incomeCategoriesProvider);
                  ref.invalidate(expenseCategoriesProvider);

                  if (ctx.mounted) Navigator.of(ctx).pop();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categoría actualizada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Ingresos'),
            Tab(text: 'Gastos'),
          ],
        ),
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
            return _buildEmptyState();
          }

          final incomeCategories = categories
              .where((c) => c.categoryHost == CategoryHost.income)
              .toList();
          final expenseCategories = categories
              .where((c) => c.categoryHost == CategoryHost.expense)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(categories),
              _buildCategoryList(incomeCategories),
              _buildCategoryList(expenseCategories),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final showDefaultsButton = _canShowDefaultsButton;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
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
          if (showDefaultsButton) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCreatingDefaults ? null : _createDefaultCategories,
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
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<domain.Category> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No hay categorías en esta sección',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allCategoriesProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) => _buildCategoryTile(categories[index]),
      ),
    );
  }

  Widget _buildCategoryTile(domain.Category category) {
    final iconData = category.icon != null
        ? IconData(int.parse(category.icon!), fontFamily: 'MaterialIcons')
        : Icons.category;

    final color = parseColorFromHex(category.color);

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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!category.isLocallyStored)
            const Tooltip(
              message: 'Solo en cloud, no guardada localmente',
              child: Icon(
                Icons.cloud_download_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
          const SizedBox(width: 4),
          _buildSyncBadge(category),
        ],
      ),
      onTap: category.isLocallyStored
          ? () => _showEditCategoryDialog(category)
          : null,
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
