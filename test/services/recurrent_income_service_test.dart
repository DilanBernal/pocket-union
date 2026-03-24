import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/services/features/recurrent_income_service.dart';
import 'package:pocket_union/domain/models/recurrent_income.dart';
import 'package:pocket_union/domain/port/local/recurrent_income_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_income_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockRecurrentIncomeLocalPort extends Mock
    implements RecurrentIncomeLocalPort {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockLoggerPort extends Mock implements LoggerPort {}

void main() {
  late RecurrentIncomeService service;
  late _MockRecurrentIncomeLocalPort mockLocal;
  late _MockSupabaseClient mockSupabase;
  late _MockLoggerPort mockLogger;

  setUp(() {
    mockLocal = _MockRecurrentIncomeLocalPort();
    mockSupabase = _MockSupabaseClient();
    mockLogger = _MockLoggerPort();
    service = RecurrentIncomeService(mockLocal, mockSupabase, mockLogger);
  });

  group('RecurrentIncomeService', () {
    test(
      'createRecurrentIncome retorna id local aunque falle Supabase',
      () async {
        const id = 'rec-income-1';
        final dto = NewRecurrentIncomeDto(
          name: 'Nomina',
          amount: 1000,
          coupleId: 'couple-1',
          createdBy: 'user-1',
          recurrentInfo: '0 9 * * 1',
        );

        when(
          () => mockLocal.createRecurrentIncome(dto),
        ).thenAnswer((_) async => id);
        when(() => mockSupabase.from(any())).thenThrow(Exception('offline'));

        final result = await service.createRecurrentIncome(dto);

        expect(result, id);
        verify(() => mockLocal.createRecurrentIncome(dto)).called(1);
      },
    );

    test(
      'getAllRecurrentIncomes retorna local cuando falla Supabase',
      () async {
        final local = [
          RecurrentIncome(
            id: 'rec-income-1',
            coupleId: 'couple-1',
            name: 'Nomina',
            amount: 1000,
            recurrentInfo: '0 9 * * 1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ];

        when(
          () => mockLocal.getAllRecurrentIncomes(),
        ).thenAnswer((_) async => local);
        when(() => mockSupabase.from(any())).thenThrow(Exception('network'));

        final result = await service.getAllRecurrentIncomes();

        expect(result, local);
        verify(() => mockLocal.getAllRecurrentIncomes()).called(1);
      },
    );
  });
}
