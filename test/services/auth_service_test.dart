import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pocket_union/core/services/auth/auth_service.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_couple_port.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/features/auth/register/domain/entities/register_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, UserLocalPort, LoggerPort, ICouplePort])
void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUserLocalPort mockUserPort;
  late MockLoggerPort mockLogger;
  late MockICouplePort mockCouplePort;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockCouplePort = MockICouplePort();
    mockUserPort = MockUserLocalPort();
    mockLogger = MockLoggerPort();
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    authService = AuthService(
      mockSupabaseClient,
      mockUserPort,
      mockCouplePort,
      sharedPreferences,
      mockLogger,
    );
  });

  group('AuthService - login', () {
    test(
      'login con credenciales inválidas retorna AuthResponse vacío y no llama upsertUser',
      () async {
        when(
          mockGoTrueClient.signInWithPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(AuthException('Invalid credentials'));

        final result = await authService.login(
          LoginDto(email: 'bad@test.com', password: 'wrong'),
        );

        expect(result.user, isNull);
        expect(result.session, isNull);
        expect(sharedPreferences.getBool('isFirstLaunch'), isFalse);
        expect(sharedPreferences.getBool('isInSession'), isNull);
        expect(sharedPreferences.getString('coupleId'), isNull);
        expect(sharedPreferences.getString('userProfile'), isNull);
        expect(sharedPreferences.getString('idUser'), isNull);
        verifyNever(mockUserPort.upsertUser(any));
      },
    );

    test(
      'login con error de red retorna AuthResponse vacío sin llamar upsertUser',
      () async {
        when(
          mockGoTrueClient.signInWithPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await authService.login(
          LoginDto(email: 'user@test.com', password: 'pass123'),
        );

        expect(result.user, isNull);
        verifyNever(mockUserPort.upsertUser(any));
      },
    );
  });

  group('AuthService - register', () {
    test('register con error de autenticación lanza la excepción', () async {
      when(
        mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        ),
      ).thenThrow(AuthException('User already registered'));

      expect(
        () => authService.register(
          RegisterCredentials(
            email: 'existing@test.com',
            fullName: 'Existing User',
            password: 'pass123',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test(
      'register con respuesta sin usuario no llama upsertUser y no falla',
      () async {
        // signUp returns an AuthResponse with no user (e.g. email confirmation pending)
        when(
          mockGoTrueClient.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => AuthResponse());

        final result = await authService.register(
          RegisterCredentials(
            email: 'pending@test.com',
            fullName: 'Pending User',
            password: 'pass123',
          ),
        );

        expect(result, isA<AuthResponse>());
        verifyNever(mockUserPort.upsertUser(any));
      },
    );

    test('register con error genérico relanza la excepción', () async {
      when(
        mockGoTrueClient.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          data: anyNamed('data'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      expect(
        () => authService.register(
          RegisterCredentials(
            email: 'new@test.com',
            fullName: 'New User',
            password: 'pass123',
          ),
        ),
        throwsException,
      );
    });
  });

  group('AuthService - logout', () {
    test(
      'logout exitoso limpia SharedPreferences y llama deleteAllUsers',
      () async {
        when(mockGoTrueClient.signOut()).thenAnswer((_) async {});
        when(mockUserPort.deleteAllUsers()).thenAnswer((_) async => true);

        await authService.logout();

        verify(mockGoTrueClient.signOut()).called(1);
        verify(mockUserPort.deleteAllUsers()).called(1);
        expect(sharedPreferences.getBool('isFirstLaunch'), isTrue);
        expect(sharedPreferences.getBool('isInSession'), isFalse);
      },
    );

    test(
      'logout con error en signOut lanza excepción y no llama deleteAllUsers',
      () async {
        when(
          mockGoTrueClient.signOut(),
        ).thenThrow(Exception('Network error during sign out'));

        expect(() => authService.logout(), throwsException);
        verifyNever(mockUserPort.deleteAllUsers());
      },
    );
  });
}
