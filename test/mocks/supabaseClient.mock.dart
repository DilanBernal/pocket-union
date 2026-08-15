class SupabaseClientMock {
  static final SupabaseClientMock _instance = SupabaseClientMock._internal();

  SupabaseClientMock._internal();

  static SupabaseClientMock get instance => _instance;
}
