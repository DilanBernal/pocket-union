import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/core/utils/supabase_client_provider.dart';
import 'package:pocket_union/ui/router.dart';

final startupRouteProvider = FutureProvider<String>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final session = supabaseClient.auth.currentSession;

  if (session == null) {
    return AppRoutes.login;
  }

  final prefs = await ref.watch(sharedPreferencesWithCacheProvider.future);
  final coupleId = prefs.getString(PreferencesCacheKeys.coupleId);

  return resolveStartupRoute(hasSession: true, coupleId: coupleId);
});

String resolveStartupRoute({
  required bool hasSession,
  required String? coupleId,
}) {
  if (!hasSession) {
    return AppRoutes.login;
  }

  if (coupleId == null || coupleId.isEmpty) {
    return AppRoutes.coupleSetup;
  }

  return AppRoutes.home;
}
