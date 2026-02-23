import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/ui/screens/transactions/in/widgets/new_entry_form.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';

class NewEntryScreen extends ConsumerWidget {
  const NewEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryServiceAsync = ref.watch(categoryServiceProvider);

    return Column(
      children: [
        const FormTitle(title: "Agregar entrada de dinero"),
        categoryServiceAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error cargando categorías: $e'),
          data: (categoryService) => _CategoriesLoader(
            categoryService: categoryService,
          ),
        ),
      ],
    );
  }
}

class _CategoriesLoader extends ConsumerStatefulWidget {
  final CategoryPort categoryService;

  const _CategoriesLoader({required this.categoryService});

  @override
  ConsumerState<_CategoriesLoader> createState() => _CategoriesLoaderState();
}

class _CategoriesLoaderState extends ConsumerState<_CategoriesLoader> {
  List<Category>? _categories;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();
    if (_error != null) return Text('Error cargando categorías: $_error');

    return NewEntryForm(categories: _categories ?? []);
  }
}
