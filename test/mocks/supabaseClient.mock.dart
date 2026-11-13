import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientMock {
  static final SupabaseClientMock _instance = SupabaseClientMock._internal();

  SupabaseClientMock._internal();

  static SupabaseClientMock get instance => _instance;
}

class MockSupabase extends Mock implements SupabaseClient {}
