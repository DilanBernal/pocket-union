import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';
@riverpod
Future<SharedPreferences> sharedPreferencesProvider (Ref ref) async {
  final instance = await SharedPreferences.getInstance();
  var isInSession = instance.getBool('isInSession');
  if (isInSession == null) {
    instance.setBool('isInSession', false);
  }
  return instance;
}