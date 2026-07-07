import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pocket_union/features/reference/category/presentation/widgets/category_command_form.dart';

class CategoryCommandScreen extends StatelessWidget {
  const CategoryCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categoría'),
          backgroundColor: Color(0xFF14091B),
          foregroundColor: Colors.white,
          centerTitle: true,
          shape: const Border(
            bottom: BorderSide(color: Color(0xFFE91E63), width: 2.0),
          ),
          leading: IconButton(
            icon: const Icon(TablerIcons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(TablerIcons.dots_vertical),
              color: const Color(
                0xFF241F2D,
              ), // fondo del menú, en línea con tu paleta
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF6A6482), width: 1),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // Navegar a edición
                    break;
                  case 'delete':
                    // Mostrar confirmación de borrado
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(TablerIcons.pencil, color: Colors.white, size: 18),
                      SizedBox(width: 12),
                      Text('Editar', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        TablerIcons.trash,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B0A1E), Color.fromARGB(255, 17, 2, 47)],
            ),
          ),
          child: CategoryCommandForm(categoryId: '2'),
        ),
      ),
    );
  }
}
