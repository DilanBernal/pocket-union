import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_union/core/providers/providers.dart';
import 'package:pocket_union/domain/port/cloud/auth/auth_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:pocket_union/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fake de AuthPort que no depende de Supabase ni SQLite.
class _FakeAuthPort implements AuthPort {
  final bool shouldLoginFail;

  _FakeAuthPort({this.shouldLoginFail = false});

  @override
  Future<AuthResponse> login(LoginDto loginRequest) async {
    if (shouldLoginFail) {
      throw AuthException('Credenciales inválidas');
    }
    return AuthResponse();
  }

  @override
  Future<AuthResponse> register(RegisterDto registerRequest) async =>
      AuthResponse();

  @override
  Future<void> logout(String email) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow - Happy Path', () {
    testWidgets('primera vez → muestra StartScreen con botón "Empezar ahora"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PocketUnionApp(isFirstLaunch: true, isInSession: false),
        ),
      );
      await tester.pump();

      // The StartScreen EnterButton should be visible
      expect(find.text('Empezar ahora'), findsOneWidget);
    });

    testWidgets(
      'no primera vez sin sesión → muestra LoginScreen con formulario',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWith(
                (ref) => Future.value(_FakeAuthPort()),
              ),
            ],
            child: const PocketUnionApp(
              isFirstLaunch: false,
              isInSession: false,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Inicia sesión'), findsOneWidget);
        expect(find.text('ACCEDER'), findsOneWidget);
      },
    );
  });

  group('App Flow - Error Cases', () {
    testWidgets(
      'Error: formulario de login vacío muestra error de validación y no crashea',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWith(
                (ref) => Future.value(_FakeAuthPort()),
              ),
            ],
            child: const PocketUnionApp(
              isFirstLaunch: false,
              isInSession: false,
            ),
          ),
        );
        await tester.pump();

        // Submit form without any data
        await tester.tap(find.text('ACCEDER'));
        await tester.pump();

        // Validation error shown, app does not crash
        expect(find.text('Por favor, ingresa tu email.'), findsOneWidget);
      },
    );

    testWidgets(
      'Error: email inválido en formulario muestra error de formato sin crashear',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWith(
                (ref) => Future.value(_FakeAuthPort()),
              ),
            ],
            child: const PocketUnionApp(
              isFirstLaunch: false,
              isInSession: false,
            ),
          ),
        );
        await tester.pump();

        // Enter an invalid email (no '@')
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'invalidemail',
        );
        await tester.tap(find.text('ACCEDER'));
        await tester.pump();

        // App shows validation error without crashing
        expect(
          find.text('Por favor, ingresa un email válido.'),
          findsOneWidget,
        );
      },
    );
  });
}
