import 'package:flutter/material.dart';
import 'package:pocket_union/features/reference/category/presentation/widgets/category_command_form.dart';

class CategoryCommandScreen extends StatelessWidget {
  const CategoryCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categoría'),
          backgroundColor: Colors.transparent,
          elevation: 5003,
          foregroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => print('Más opciones'),
            ),
          ],
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B0A1E), Color(0xFF13091A)],
            ),
          ),
          child: CategoryCommandForm(categoryId: '2'),
        ),
      ),
    );
  }
}
