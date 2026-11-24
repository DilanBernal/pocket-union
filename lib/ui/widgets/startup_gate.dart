import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/utils/startup_route_provider.dart';
import 'package:pocket_union/ui/router.dart';

class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupRoute = ref.watch(startupRouteProvider);

    return startupRoute.when(
      loading: () => const _StartupSplash(),
      error: (error, _) => _StartupError(
        error: error,
        onRetry: () => ref.invalidate(startupRouteProvider),
      ),
      data: (routeName) {
        final builder = AppRoutes.routes[routeName];
        if (builder == null) {
          return _StartupError(
            error: StateError('Ruta inicial no registrada: $routeName'),
            onRetry: () => ref.invalidate(startupRouteProvider),
          );
        }
        return builder(context);
      },
    );
  }
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color.fromRGBO(27, 7, 35, 1),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

class _StartupError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _StartupError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color.fromRGBO(27, 7, 35, 1),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No se pudo verificar tu sesión.',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
