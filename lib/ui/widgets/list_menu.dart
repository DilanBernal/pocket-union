import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers.dart';
import 'package:pocket_union/ui/router.dart';

class ListMenu extends ConsumerStatefulWidget {
  const ListMenu({super.key});

  @override
  ConsumerState<ListMenu> createState() => _ListMenuState();
}

class _ListMenuState extends ConsumerState<ListMenu> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (mounted) {
      setState(() {
        _isLoggingOut = true;
      });
    }

    try {
      final authService = await ref.read(authServiceProvider.future);
      await authService.logout("");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada correctamente'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to login screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.start);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(currentUserProvider);

    return ListView(
      children: <Widget>[
        // Header con información del usuario
        userAsyncValue.when(
          data: (user) => DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(46, 0, 76, 0.75),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar del usuario
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: user?.avatarUrl != null
                      ? Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person,
                          size: 30, color: Color.fromRGBO(46, 0, 76, 0.75)),
                ),
                const SizedBox(height: 12),
                // Nombre del usuario
                Text(
                  user?.fullName ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Nuestras finanzas ❤️',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          loading: () => DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(46, 0, 76, 0.75),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (err, stack) => DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(46, 0, 76, 0.75),
            ),
            child: const Center(
              child: Text(
                "Error cargando usuario",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        // Opciones del menú
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Historial de gastos'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/history-expenses');
          },
        ),
        ListTile(
          leading: const Icon(Icons.trending_up),
          title: const Text('Historial de ingresos'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/history-income');
          },
        ),
        ListTile(
          leading: const Icon(Icons.emoji_events),
          title: const Text('Misiones (metas)'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/missions');
          },
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Categorías'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/categories');
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuración'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        ),
        const Divider(),
        // Logout button
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.red),
          ),
          onTap: _isLoggingOut
              ? null
              : () {
                  // Navigator.pop(context); // Quitar esto para no disponer el widget
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                          '¿Estás seguro de que deseas cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: _isLoggingOut
                              ? null
                              : () {
                                  Navigator.pop(context); // Cierra el diálogo
                                  _handleLogout();
                                },
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
        ),
      ],
    );
  }
}
