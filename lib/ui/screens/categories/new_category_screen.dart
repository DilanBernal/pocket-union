import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/ui/screens/categories/widgets/new_category_form.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';

class NewCategoryScreen extends ConsumerWidget {
  const NewCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Categoría'),
        backgroundColor: const Color.fromRGBO(46, 0, 76, 0.75),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FormTitle(title: 'Crear categoría'),
              NewCategoryForm(),
            ],
          ),
        ),
      ),
    );
  }
}
