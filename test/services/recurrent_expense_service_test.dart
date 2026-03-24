import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/services/features/recurrent_expense_service.dart';
import 'package:pocket_union/domain/models/recurrent_expense.dart';
import 'package:pocket_union/domain/port/local/recurrent_expense_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_expense_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockRecurrentExpenseLocalPort extends Mock
    implements RecurrentExpenseLocalPort {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockLoggerPort extends Mock implements LoggerPort {}

void main() {
  late RecurrentExpenseService service;
  late _MockRecurrentExpenseLocalPort mockLocal;
  late _MockSupabaseClient mockSupabase;
  late _MockLoggerPort mockLogger;

  setUp(() {
    mockLocal = _MockRecurrentExpenseLocalPort();
    mockSupabase = _MockSupabaseClient();
    mockLogger = _MockLoggerPort();
    service = RecurrentExpenseService(mockLocal, mockSupabase, mockLogger);
  });

  group('RecurrentExpenseService', () {
    test(
      'createRecurrentExpense retorna id local aunque falle Supabase',
      () async {
        const id = 'rec-expense-1';
        final dto = NewRecurrentExpenseDto(
          name: 'Arriendo',
          amount: 800,
          coupleId: 'couple-1',
          createdBy: 'user-1',
          recurrentInfo: '0 8 1 * *',
        );

        when(
          () => mockLocal.createRecurrentExpense(dto),
        ).thenAnswer((_) async => id);
        when(() => mockSupabase.from(any())).thenThrow(Exception('offline'));

        final result = await service.createRecurrentExpense(dto);

        expect(result, id);
        verify(() => mockLocal.createRecurrentExpense(dto)).called(1);
      },
    );

    test(
      'getAllRecurrentExpenses retorna local cuando falla Supabase',
      () async {
        final local = [
          RecurrentExpense(
            id: 'rec-expense-1',
            coupleId: 'couple-1',
            createdBy: 'user-1',
            name: 'Arriendo',
            amount: 800,
            recurrentInfo: '0 8 1 * *',
            createdAt: DateTime(2026, 1, 1),
          ),
        ];

        when(
          () => mockLocal.getAllRecurrentExpenses(),
        ).thenAnswer((_) async => local);
        when(() => mockSupabase.from(any())).thenThrow(Exception('network'));

        final result = await service.getAllRecurrentExpenses();

        expect(result, local);
        verify(() => mockLocal.getAllRecurrentExpenses()).called(1);
      },
    );
  });
}
