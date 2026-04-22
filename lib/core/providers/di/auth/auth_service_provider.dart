import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_cloud_providers.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';

import '../../../../domain/port/cloud/auth/i_auth_port.dart';
import '../../../services/auth/auth_service.dart';


final authServiceProvider = FutureProvider<IAuthPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final userSqlite = ref.watch(userDaoProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final logger = ref.watch(loggerProvider);
  final coupleService = await ref.watch(coupleServiceProvider.future);
  return AuthService(supabaseClient, userSqlite, coupleService, prefs, logger);
});

