
// Current couple (Supabase first, fallback local)
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/couple.dart';
import '../../data_cloud_providers.dart';
import '../../data_local_providers.dart';
import '../../utils_providers.dart';

final currentCoupleNotifier = FutureProvider<Couple?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final userId = prefs.getString('idUser');
  if (userId == null) return null;

  try {
    final coupleService = await ref.watch(coupleServiceProvider.future);
    final couple = await coupleService.getCoupleByUserId(userId);
    if (couple != null) {
      await prefs.setString('coupleId', couple.id);
    }
    return couple;
  } catch (_) {
    final coupleDao = ref.watch(coupleDaoProvider);
    return coupleDao.getCoupleByUserId(userId);
  }
});