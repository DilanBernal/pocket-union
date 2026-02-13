import 'dart:io';

void main() async {
  // Create test/services directory
  final servicesDir = Directory('test/services');
  if (!await servicesDir.exists()) {
    await servicesDir.create(recursive: true);
    print('✅ Created test/services directory');
  }

  // Copy the test file
  final testContent = '''import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pocket_union/core/services/auth/auth_service.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/feat/user_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([
  SupabaseClient,
  UserPort,
  GoTrueClient,
  User,
  Session,
])
void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockUserPort mockUserPort;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockUserPort = MockUserPort();
    mockGoTrueClient = MockGoTrueClient();
    authService = AuthService(mockSupabaseClient, mockUserPort);

    // Setup Supabase client to return the mock auth client
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  group('AuthService - login', () {
    test('login exitoso debe llamar signInWithPassword y upsertUser', () async {
      // Arrange
      final loginDto = LoginDto(
        email: 'test@example.com',
        password: 'password123',
      );

      final mockUser = MockUser();
      when(mockUser.id).thenReturn('test-user-id');

      final mockSession = MockSession();
      final authResponse = AuthResponse(
        user: mockUser,
        session: mockSession,
      );

      when(mockGoTrueClient.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => authResponse);

      when(mockUserPort.upsertUser(any)).thenAnswer((_) async => true);

      // Act
      final result = await authService.login(loginDto);

      // Assert
      expect(result.user, isNotNull);
      expect(result.user!.id, 'test-user-id');

      verify(mockGoTrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);

      verify(mockUserPort.upsertUser(argThat(
        predicate<DomainUser>((user) =>
            user.id == 'test-user-id' &&
            user.fullName == 'Prueba por ahora' &&
            user.balance == 0 &&
            user.inCloud == true),
      ))).called(1);
    });

    test('login con error debe retornar AuthResponse vacío', () async {
      // Arrange
      final loginDto = LoginDto(
        email: 'test@example.com',
        password: 'wrong-password',
      );

      when(mockGoTrueClient.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(AuthException('Invalid credentials'));

      // Act
      final result = await authService.login(loginDto);

      // Assert
      expect(result.user, isNull);
      expect(result.session, isNull);

      verify(mockGoTrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'wrong-password',
      )).called(1);

      verifyNever(mockUserPort.upsertUser(any));
    });
  });

  group('AuthService - register', () {
    test('register exitoso debe llamar signUp y upsertUser', () async {
      // Arrange
      final registerDto = RegisterDto(
        email: 'newuser@example.com',
        fullName: 'New User',
        password: 'password123',
      );

      final mockUser = MockUser();
      when(mockUser.id).thenReturn('new-user-id');

      final mockSession = MockSession();
      final authResponse = AuthResponse(
        user: mockUser,
        session: mockSession,
      );

      when(mockGoTrueClient.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => authResponse);

      when(mockUserPort.upsertUser(any)).thenAnswer((_) async => true);

      // Act
      final result = await authService.register(registerDto);

      // Assert
      expect(result.user, isNotNull);
      expect(result.user!.id, 'new-user-id');

      verify(mockGoTrueClient.signUp(
        email: 'newuser@example.com',
        password: 'password123',
        data: {
          'fullName': 'New User',
          'full_name': 'New User',
        },
      )).called(1);

      verify(mockUserPort.upsertUser(argThat(
        predicate<DomainUser>((user) =>
            user.id == 'new-user-id' &&
            user.fullName == 'New User' &&
            user.balance == 0 &&
            user.inCloud == true),
      ))).called(1);
    });

    test('register con error debe lanzar excepción', () async {
      // Arrange
      final registerDto = RegisterDto(
        email: 'existing@example.com',
        fullName: 'Existing User',
        password: 'password123',
      );

      when(mockGoTrueClient.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        data: anyNamed('data'),
      )).thenThrow(AuthException('User already exists'));

      // Act & Assert
      expect(
        () => authService.register(registerDto),
        throwsA(isA<AuthException>()),
      );

      verify(mockGoTrueClient.signUp(
        email: 'existing@example.com',
        password: 'password123',
        data: anyNamed('data'),
      )).called(1);

      verifyNever(mockUserPort.upsertUser(any));
    });
  });

  group('AuthService - logout', () {
    test('logout exitoso debe llamar signOut, deleteAllUsers y limpiar SharedPreferences',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      when(mockGoTrueClient.signOut()).thenAnswer((_) async => null);
      when(mockUserPort.deleteAllUsers()).thenAnswer((_) async => true);

      // Act
      await authService.logout('test@example.com');

      // Assert
      verify(mockGoTrueClient.signOut()).called(1);
      verify(mockUserPort.deleteAllUsers()).called(1);

      // Verify SharedPreferences was reset
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isFirstLaunch'), isTrue);
    });

    test('logout con error debe relanzar excepción', () async {
      // Arrange
      when(mockGoTrueClient.signOut())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => authService.logout('test@example.com'),
        throwsException,
      );

      verify(mockGoTrueClient.signOut()).called(1);
      verifyNever(mockUserPort.deleteAllUsers());
    });

    test('logout con error en deleteAllUsers debe relanzar excepción',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      when(mockGoTrueClient.signOut()).thenAnswer((_) async => null);
      when(mockUserPort.deleteAllUsers())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => authService.logout('test@example.com'),
        throwsException,
      );

      verify(mockGoTrueClient.signOut()).called(1);
      verify(mockUserPort.deleteAllUsers()).called(1);
    });
  });
}
''';

  final testFile = File('test/services/auth_service_test.dart');
  await testFile.writeAsString(testContent);
  print('✅ Created test/services/auth_service_test.dart');

  print('\\n📦 Now run: dart pub get');
  print(
    '🏗️  Then run: dart run build_runner build --delete-conflicting-outputs',
  );
  print('🧪 Finally run: flutter test test/services/auth_service_test.dart');
}
