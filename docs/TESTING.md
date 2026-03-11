# Testing - Pocket Union

## Estructura de Tests

```
test/
├── widget_test.dart              # Smoke test: verifica que la app arranca
├── services/
│   ├── auth_service_test.dart    # Tests de AuthService (login, register, logout)
│   ├── auth_service_test.mocks.dart  # Mocks generados por Mockito
│   ├── category_service_test.dart    # Tests de CategoryService (CRUD, host filter)
│   ├── category_service_test.mocks.dart
│   ├── income_service_test.dart      # Tests de IncomeService (create, getAllIncomes)
│   └── income_service_test.mocks.dart
└── widget/
    └── app_widget_test.dart      # Widget tests de StartScreen, LoginScreen, routing

integration_test/
└── app_flow_test.dart            # Integration tests del flujo de navegación
```

## Dependencias de Testing

| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter_test` | SDK | Framework base de tests |
| `mockito` | ^5.4.6 | Generación de mocks |
| `build_runner` | ^2.4.13 | Code generation para mocks |
| `integration_test` | SDK | Integration tests |

## Convenciones

### Naming

- Archivos de test: `{feature}_test.dart`
- Mocks generados: `{feature}_test.mocks.dart`
- Fakes manuales: `_FakeXxxPort` (privadas, dentro del test)

### Tipos de Mock

1. **Mocks de Mockito** (`@GenerateMocks`): Para ports/DAOs inyectados en services.

   ```dart
   @GenerateMocks([CategoryLocalPort, SupabaseClient, LoggerPort])
   ```

2. **Fakes manuales**: Para overrides de providers en widget/integration tests.

   ```dart
   class _FakeAuthPort implements IAuthPort { ... }
   ```

### Patrón de Test de Service

Cada service test sigue este patrón:

```dart
@GenerateMocks([XxxLocalPort, SupabaseClient, LoggerPort])
void main() {
  late XxxService service;
  late MockXxxLocalPort mockDao;
  late MockSupabaseClient mockSupabaseClient;
  late MockLoggerPort mockLogger;

  setUp(() {
    mockDao = MockXxxLocalPort();
    mockSupabaseClient = MockSupabaseClient();
    mockLogger = MockLoggerPort();
    service = XxxService(mockDao, mockSupabaseClient, mockLogger);
  });

  // Tests agrupados por método
  group('XxxService - methodName', () {
    test('caso exitoso', () async { ... });
    test('error propaga excepción', () async { ... });
    test('offline-first: retorna resultado aunque Supabase falle', () async { ... });
  });
}
```

### Qué se mockea

| Mock | Puerto/Clase | Razón |
|------|-------------|-------|
| `MockCategoryLocalPort` | `CategoryLocalPort` | DAO inyectado en `CategoryService` |
| `MockIncomeLocalPort` | `IncomeLocalPort` | DAO inyectado en `IncomeService` |
| `MockUserLocalPort` | `UserLocalPort` | DAO inyectado en `AuthService` |
| `MockSupabaseClient` | `SupabaseClient` | Cliente cloud (no queremos requests reales) |
| `MockGoTrueClient` | `GoTrueClient` | Auth client de Supabase |
| `MockLoggerPort` | `LoggerPort` | Logger inyectado (evita output en tests) |

## Comandos

### Ejecutar todos los tests

```bash
flutter test
```

### Ejecutar un archivo específico

```bash
flutter test test/services/auth_service_test.dart
```

### Regenerar mocks después de cambiar ports/interfaces

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Ejecutar integration tests (requiere emulador/dispositivo)

```bash
flutter test integration_test/
```

## Cobertura Actual

| Service | Tests | Métodos cubiertos |
|---------|-------|-------------------|
| `AuthService` | 6 | `login` (2), `register` (3), `logout` (2) |
| `CategoryService` | 10 | `getAllCategories` (3), `getCategoriesByHost` (4), `createCategory` (3) |
| `IncomeService` | 11 | `getAllIncomes` (3), `createIncome` (8: offline-first, dto fields) |
| **Total** | **27** | |

### Servicios sin tests (próximos a implementar)

- `CoupleService` — create, join, getCoupleByUserId, getCoupleByInviteCode
- `ExpenseService` — createExpense, getAllExpenses, deleteExpense
- `ExpenseShareService` — createExpenseShare, getSharesByExpense, deleteExpenseShare
- `GoalService` — createGoal, getAllGoals, updateGoal, deleteGoal
- `GoalContributionService` — createContribution, getContributionsByGoal, deleteContribution

## Notas

- Los tests de service verifican el patrón **offline-first**: DAO local siempre se ejecuta primero, Supabase falla en silencio.
- `SharedPreferences.setMockInitialValues({})` se llama en setUp para tests que usan SharedPreferences.
- Los widget tests usan `ProviderScope(overrides: [...])` para inyectar fakes.
- Los `.mocks.dart` son **auto-generados** — nunca editarlos manualmente.
