import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferencesAsync> sharedPreferencesAsync(Ref ref) async {
  final prefs = SharedPreferencesAsync();
  return prefs;
}

@Riverpod(keepAlive: true)
Future<SharedPreferencesWithCache> sharedPreferencesWithCache(Ref ref) async {
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(
      allowList: {
        PreferencesCacheKeys.isFirstLaunch,
        PreferencesCacheKeys.isInSession,
        PreferencesCacheKeys.coupleId,
        PreferencesCacheKeys.userId,
      },
    ),
  );
  return prefs;
}

class PreferencesCacheKeys {
  static const String isFirstLaunch = 'isFirstLaunch';
  static const String isInSession = 'isInSession';
  static const String coupleId = 'coupleId';
  static const String userId = 'userId';
}
