import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/features/home/domain/entities/couple_balance_entity.dart';
import 'package:pocket_union/features/home/domain/entities/couple_transaction_entity.dart';

void main() {
  group('CoupleBalanceEntity', () {
    test('maps Supabase numeric fields', () {
      final entity = CoupleBalanceEntity.fromMap({
        'couple_id': 'couple-1',
        'total_income': 250000,
        'total_expense': 125000,
        'balance': 125000,
      });

      expect(entity.coupleId, 'couple-1');
      expect(entity.totalIncome, 250000);
      expect(entity.totalExpense, 125000);
      expect(entity.balance, 125000);
    });
  });

  group('CoupleTransactionEntity', () {
    test('maps an income transaction', () {
      final entity = CoupleTransactionEntity.fromMap({
        'id': 'income-1',
        'couple_id': 'couple-1',
        'type': 'income',
        'amount': 50000,
        'description': 'Nomina',
        'transaction_date': '2026-11-19T02:00:00Z',
        'created_by': 'user-1',
        'name': 'Pago',
        'is_paid': null,
      });

      expect(entity.type, CoupleTransactionType.income);
      expect(entity.amount, 50000);
      expect(entity.name, 'Pago');
      expect(entity.isPaid, false);
      expect(entity.transactionDate.isUtc, true);
    });

    test('maps an expense transaction', () {
      final entity = CoupleTransactionEntity.fromMap({
        'id': 'expense-1',
        'couple_id': 'couple-1',
        'type': 'expense',
        'amount': 25000,
        'description': 'Mercado',
        'transaction_date': '2026-11-18T12:00:00Z',
        'created_by': 'user-1',
        'name': 'Supermercado',
        'is_paid': false,
      });

      expect(entity.type, CoupleTransactionType.expense);
      expect(entity.amount, 25000);
      expect(entity.isPaid, false);
    });
  });
}
