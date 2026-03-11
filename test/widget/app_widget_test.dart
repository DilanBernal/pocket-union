import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_auth_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:pocket_union/core/providers/providers.dart';
import 'package:pocket_union/main.dart';
import 'package:pocket_union/ui/screens/auth/login_screen.dart';
import 'package:pocket_union/ui/screens/start/start_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fake de IAuthPort que no llama a servicios externos.
class _FakeAuthPort implements IAuthPort {
  @override
  Future<AuthResponse> login(LoginDto loginRequest) async => AuthResponse();

  @override
  Future<AuthResponse> register(RegisterDto registerRequest) async =>
      AuthResponse();

  @override
  Future<void> logout(String email) async {}
}

void main() {
  group('StartScreen - widget', () {
    testWidgets('muestra el botón "Empezar ahora" correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StartScreen())),
      );
      // Just one pump – image loading is async but text should be visible
      await tester.pump();

      expect(find.text('Empezar ahora'), findsOneWidget);
    });
  });

  group('LoginScreen - widget', () {
    Widget buildLoginScreen() {
      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWith(
            (ref) => Future.value(_FakeAuthPort()),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LoginScreen())),
      );
    }

    testWidgets('muestra los campos de email, contraseña y botón de acceso', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('ACCEDER'), findsOneWidget);
    });

    testWidgets(
      'Error: al enviar formulario vacío muestra error de email requerido',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pump();

        // Tap submit with empty fields
        await tester.tap(find.text('ACCEDER'));
        await tester.pump();

        expect(find.text('Por favor, ingresa tu email.'), findsOneWidget);
      },
    );

    testWidgets(
      'Error: email sin @ muestra error de formato de email inválido',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pump();

        // Enter an email without '@'
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'notanemail',
        );
        // Move focus away to trigger onUnfocus validation
        await tester.tap(find.text('ACCEDER'));
        await tester.pump();

        expect(
          find.text('Por favor, ingresa un email válido.'),
          findsOneWidget,
        );
      },
    );
  });

  group('PocketUnionApp - routing', () {
    testWidgets(
      'Happy path: primera vez → ruta inicial es StartScreen (contiene "Empezar ahora")',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: PocketUnionApp(initialRoute: '/')),
        );
        await tester.pump();

        expect(find.text('Empezar ahora'), findsOneWidget);
      },
    );

    testWidgets(
      'Happy path: no primera vez y sin sesión → ruta inicial es LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWith(
                (ref) => Future.value(_FakeAuthPort()),
              ),
            ],
            child: const PocketUnionApp(initialRoute: '/login'),
          ),
        );
        await tester.pump();

        expect(find.text('Inicia sesión'), findsOneWidget);
      },
    );
  });
}
