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
    final categoriesAsync = ref.watch(categoryServiceProvider);

    return Column(
      children: [
        const FormTitle(title: 'Agregar entrada de dinero'),
        categoriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error al cargar el servicio: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (categoryService) => _CategoriesLoader(
            categoryService: categoryService,
          ),
        ),
      ],
    );
  }
}

class _CategoriesLoader extends ConsumerStatefulWidget {
  const _CategoriesLoader({required this.categoryService});

  final CategoryPort categoryService;

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
      final categories = await widget.categoryService.getAllCategories();
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
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error al cargar categorías: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return NewEntryForm(categories: _categories ?? []);
  }
}
