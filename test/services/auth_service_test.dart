import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/services/auth/auth_service.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_couple_port.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/features/auth/register/domain/entities/register_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUserLocalPort extends Mock implements UserLocalPort {}

class _MockLoggerPort extends Mock implements LoggerPort {}

class _MockICouplePort extends Mock implements ICouplePort {}

void main() {
  late AuthService authService;
  late _MockSupabaseClient mockSupabaseClient;
  late _MockGoTrueClient mockGoTrueClient;
  late _MockUserLocalPort mockUserPort;
  late _MockLoggerPort mockLogger;
  late _MockICouplePort mockCouplePort;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    mockSupabaseClient = _MockSupabaseClient();
    mockGoTrueClient = _MockGoTrueClient();
    mockCouplePort = _MockICouplePort();
    mockUserPort = _MockUserLocalPort();
    mockLogger = _MockLoggerPort();
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
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
          () => mockGoTrueClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
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
        verifyNever(() => mockUserPort.upsertUser(any()));
      },
    );

    test(
      'login con error de red retorna AuthResponse vacío sin llamar upsertUser',
      () async {
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await authService.login(
          LoginDto(email: 'user@test.com', password: 'pass123'),
        );

        expect(result.user, isNull);
        verifyNever(() => mockUserPort.upsertUser(any()));
      },
    );
  });

  group('AuthService - register', () {
    test('register con error de autenticación lanza la excepción', () async {
      when(
        () => mockGoTrueClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
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
        when(
          () => mockGoTrueClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
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
        verifyNever(() => mockUserPort.upsertUser(any()));
      },
    );

    test('register con error genérico relanza la excepción', () async {
      when(
        () => mockGoTrueClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
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
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});
        when(() => mockUserPort.deleteAllUsers()).thenAnswer((_) async => true);

        await authService.logout();

        verify(() => mockGoTrueClient.signOut()).called(1);
        verify(() => mockUserPort.deleteAllUsers()).called(1);
        expect(sharedPreferences.getBool('isFirstLaunch'), isTrue);
        expect(sharedPreferences.getBool('isInSession'), isFalse);
      },
    );

    test(
      'logout con error en signOut lanza excepción y no llama deleteAllUsers',
      () async {
        when(
          () => mockGoTrueClient.signOut(),
        ).thenThrow(Exception('Network error during sign out'));

        expect(() => authService.logout(), throwsException);
        verifyNever(() => mockUserPort.deleteAllUsers());
      },
    );
  });
}
