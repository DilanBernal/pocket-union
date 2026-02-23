import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pocket_union/core/services/features/income_service.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/feat/income_port.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'income_service_test.mocks.dart';

@GenerateMocks([IncomePort, SupabaseClient])
void main() {
  late IncomeService incomeService;
  late MockIncomePort mockIncomeDao;
  late MockSupabaseClient mockSupabaseClient;

  final testIncome = Income(
    id: 'income-uuid-1',
    name: 'Sueldo',
    transactionDate: DateTime(2024, 1, 15),
    amount: 150000,
    createdAt: DateTime(2024, 1, 15),
    inCloud: false,
    categoryId: 'cat-1',
    isReceived: true,
  );

  setUp(() {
    mockIncomeDao = MockIncomePort();
    mockSupabaseClient = MockSupabaseClient();
    incomeService = IncomeService(mockIncomeDao, mockSupabaseClient);
  });

  group('IncomeService - getAllIncomes', () {
    test('retorna lista de ingresos desde el DAO local', () async {
      when(mockIncomeDao.getAllIncomes())
          .thenAnswer((_) async => [testIncome]);

      final result = await incomeService.getAllIncomes();

      expect(result, hasLength(1));
      expect(result.first.name, 'Sueldo');
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
        throwsException,
      );
    });
  });

  group('IncomeService - createIncome', () {
    final newIncomeDto = NewIncomeDto(
      name: 'Sueldo enero',
      amount: 1500.00,
      categoryId: 'cat-uuid-1',
      isReceived: true,
      userId: 'user-uuid-1',
      description: 'Pago mensual',
    );

    test('inserta en SQLite y devuelve el ID generado', () async {
      const generatedId = 'income-uuid-new';
      when(mockIncomeDao.createIncome(any))
          .thenAnswer((_) async => generatedId);
      // Supabase falla en silencio (offline-first)
      when(mockSupabaseClient.from(any)).thenThrow(Exception('offline'));

      final result = await incomeService.createIncome(newIncomeDto);

      expect(result, generatedId);
      verify(mockIncomeDao.createIncome(any)).called(1);
    });

    test('retorna ID aunque falle la sincronización con Supabase', () async {
      const generatedId = 'income-uuid-offline';
      when(mockIncomeDao.createIncome(any))
          .thenAnswer((_) async => generatedId);
      when(mockSupabaseClient.from(any)).thenThrow(Exception('Network error'));

      final result = await incomeService.createIncome(newIncomeDto);

      expect(result, generatedId);
      verify(mockIncomeDao.createIncome(any)).called(1);
    });

    test('lanza excepción si el DAO falla', () async {
      when(mockIncomeDao.createIncome(any))
          .thenThrow(Exception('SQLite error'));

      expect(
        () => incomeService.createIncome(newIncomeDto),
        throwsException,
      );
    });

    test('isReceived=true (solo yo) se pasa correctamente al DAO', () async {
      when(mockIncomeDao.createIncome(any))
          .thenAnswer((_) async => 'id-me');
      when(mockSupabaseClient.from(any)).thenThrow(Exception('offline'));

      final dto = NewIncomeDto(
        name: 'Bono',
        amount: 500.0,
        categoryId: 'cat-2',
        isReceived: true,
        userId: 'user-1',
      );

      await incomeService.createIncome(dto);

      final captured =
          verify(mockIncomeDao.createIncome(captureAny)).captured.single
              as NewIncomeDto;
      expect(captured.isReceived, isTrue);
      expect(captured.userId, 'user-1');
      expect(captured.name, 'Bono');
    });

    test('isReceived=false (ambos) se pasa correctamente al DAO', () async {
      when(mockIncomeDao.createIncome(any))
          .thenAnswer((_) async => 'id-both');
      when(mockSupabaseClient.from(any)).thenThrow(Exception('offline'));

      final dto = NewIncomeDto(
        name: 'Dividendos',
        amount: 2000.0,
        categoryId: 'cat-3',
        isReceived: false,
        userId: 'user-2',
      );

      await incomeService.createIncome(dto);

      final captured =
          verify(mockIncomeDao.createIncome(captureAny)).captured.single
              as NewIncomeDto;
      expect(captured.isReceived, isFalse);
    });
  });
}
