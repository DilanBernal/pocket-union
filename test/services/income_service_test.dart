import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pocket_union/core/services/features/income_service.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/feat/income_port.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'income_service_test.mocks.dart';

@GenerateMocks([IncomePort])
void main() {
  late IncomeService incomeService;
  late MockIncomePort mockIncomeDao;
  late _FakeSupabaseClient fakeSupabase;

  final tIncome = Income(
    id: 'income-uuid-1',
    name: 'Salario mensual',
    transactionDate: DateTime(2024, 1, 1),
    amount: 5000.0,
    createdAt: DateTime(2024, 1, 1),
    inCloud: false,
  );

  final tDto = NewIncomeDto(
    name: 'Salario mensual',
    amount: 5000.0,
    importanceLevel: 3,
    categoryId: 'cat-uuid-1',
    isRecurring: false,
    isReceived: true,
    userRecipientId: 'user-uuid-1',
    description: 'Pago de enero',
  );

  setUp(() {
    mockIncomeDao = MockIncomePort();
    fakeSupabase = _FakeSupabaseClient();
    incomeService = IncomeService(mockIncomeDao, fakeSupabase);
  });

  group('IncomeService - createIncome', () {
    test('inserta en DAO y retorna id generado', () async {
      when(mockIncomeDao.createIncome(tDto))
          .thenAnswer((_) async => 'income-uuid-1');

      final result = await incomeService.createIncome(tDto);

      expect(result, 'income-uuid-1');
      verify(mockIncomeDao.createIncome(tDto)).called(1);
    });

    test('retorna id aunque Supabase falle (offline-first)', () async {
      // _FakeSupabaseClient siempre lanza excepción, simulando fallo de red
      when(mockIncomeDao.createIncome(tDto))
          .thenAnswer((_) async => 'income-uuid-1');

      final result = await incomeService.createIncome(tDto);

      expect(result, 'income-uuid-1');
      verify(mockIncomeDao.createIncome(tDto)).called(1);
    });

    test('propaga excepción si el DAO falla', () async {
      when(mockIncomeDao.createIncome(tDto))
          .thenThrow(Exception('DB insert error'));

      expect(
        () => incomeService.createIncome(tDto),
        throwsA(isA<Exception>()),
      );
    });

    test('llama al DAO con los datos correctos del DTO', () async {
      final customDto = NewIncomeDto(
        name: 'Freelance',
        amount: 1500.0,
        importanceLevel: 2,
        categoryId: 'cat-uuid-2',
        isRecurring: false,
        isReceived: false,
        userRecipientId: 'user-uuid-2',
      );

      when(mockIncomeDao.createIncome(customDto))
          .thenAnswer((_) async => 'income-uuid-2');

      final result = await incomeService.createIncome(customDto);

      expect(result, 'income-uuid-2');
      verify(mockIncomeDao.createIncome(customDto)).called(1);
    });
  });

  group('IncomeService - getAllIncomes', () {
    test('retorna lista de ingresos del DAO', () async {
      when(mockIncomeDao.getAllIncomes())
          .thenAnswer((_) async => [tIncome]);

      final result = await incomeService.getAllIncomes();

      expect(result, [tIncome]);
      verify(mockIncomeDao.getAllIncomes()).called(1);
    });

    test('retorna lista vacía cuando no hay ingresos', () async {
      when(mockIncomeDao.getAllIncomes()).thenAnswer((_) async => []);

      final result = await incomeService.getAllIncomes();

      expect(result, isEmpty);
      verify(mockIncomeDao.getAllIncomes()).called(1);
    });

    test('propaga excepción del DAO', () async {
      when(mockIncomeDao.getAllIncomes()).thenThrow(Exception('DB error'));

      expect(
        () => incomeService.getAllIncomes(),
        throwsA(isA<Exception>()),
      );
    });
  });
}

/// Fake SupabaseClient que lanza excepción en cualquier llamada de red,
/// simulando un entorno offline para verificar el comportamiento offline-first.
class _FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) {
    throw Exception('Test: Supabase unavailable');
  }
}

