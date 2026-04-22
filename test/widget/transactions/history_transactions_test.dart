import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/core/providers/providers.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_expense_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_income_port.dart';
import 'package:pocket_union/dto/new_expense_dto.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:pocket_union/ui/screens/transactions/exp/history_expenses_screen.dart';
import 'package:pocket_union/ui/screens/transactions/in/history_income_screen.dart';

class _FakeExpenseService implements IExpensePort {
  _FakeExpenseService(this.expenses);

  final List<Expense> expenses;
  final List<String> deletedIds = [];

  @override
  Future<String> createExpense(NewExpenseDto dto) async => 'expense-id';

  @override
  Future<bool> deleteExpense(String id) async {
    deletedIds.add(id);
    return true;
  }

  @override
  Future<List<Expense>> getAllExpenses() async => expenses;

  @override
  Future<Expense?> getExpenseById(String id) async => null;

  @override
  Future<bool> updateExpense(String id, NewExpenseDto dto) async => true;
}

class _FakeIncomeService implements IIncomePort {
  _FakeIncomeService(this.incomes);

  final List<Income> incomes;
  final List<String> deletedIds = [];

  @override
  Future<String> createIncome(NewIncomeDto dto) async => 'income-id';

  @override
  Future<bool> deleteIncome(String id) async {
    deletedIds.add(id);
    return true;
  }

  @override
  Future<List<Income>> getAllIncomes() async => incomes;

  @override
  Future<Income?> getIncomeById(String id) async => null;

  @override
  Future<bool> updateIncome(String id, NewIncomeDto dto) async => true;
}

Category _category() {
  return Category(
    id: 'cat-1',
    coupleId: 'couple-1',
    name: 'General',
    icon: '58834',
    createdAt: DateTime(2024, 1, 1),
    categoryHost: CategoryHost.expense,
    syncStatus: SyncStatus.synced,
  );
}

Expense _expense() {
  return Expense(
    id: 'exp-1',
    coupleId: 'couple-1',
    createdBy: 'user-1',
    name: 'Mercado',
    amount: 100.5,
    categoryIds: const ['cat-1'],
    importanceLevel: 1,
    createdAt: DateTime(2024, 1, 1),
  );
}

Income _income() {
  return Income(
    id: 'inc-1',
    coupleId: 'couple-1',
    name: 'Salario',
    transactionDate: DateTime(2024, 1, 1),
    amount: 1200,
    categoryIds: const ['cat-1'],
    createdAt: DateTime(2024, 1, 1),
  );
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 12, height: 1),
        bodySmall: TextStyle(fontSize: 11, height: 1),
        titleMedium: TextStyle(fontSize: 13, height: 1),
      ),
    ),
    home: child,
  );
}

void main() {
  group('Transaction history screens', () {
    testWidgets('expenses empty state shows refresh button', (tester) async {
      final expenseService = _FakeExpenseService([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWith((ref) async => expenseService),
            expenseCategoriesForTransactionProvider.overrideWith(
              (ref) async => <Category>[],
            ),
          ],
          child: _testApp(const HistoryExpensesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Actualizar'), findsOneWidget);
    });

    testWidgets('income empty state shows refresh button', (tester) async {
      final incomeService = _FakeIncomeService([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allIncomesProvider.overrideWith((ref) async => <Income>[]),
            incomeServiceProvider.overrideWith((ref) async => incomeService),
            incomeCategoriesForTransactionProvider.overrideWith(
              (ref) async => <Category>[],
            ),
          ],
          child: _testApp(const HistoryIncomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Actualizar'), findsOneWidget);
    });

    testWidgets('expenses list renders dismissible item', (tester) async {
      final expenseService = _FakeExpenseService([_expense()]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWith((ref) async => expenseService),
            expenseCategoriesForTransactionProvider.overrideWith(
              (ref) async => <Category>[_category()],
            ),
          ],
          child: _testApp(const HistoryExpensesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsOneWidget);
      expect(expenseService.deletedIds, isEmpty);
    });

    testWidgets('income list renders dismissible item', (tester) async {
      final incomeService = _FakeIncomeService([_income()]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allIncomesProvider.overrideWith((ref) async => <Income>[_income()]),
            incomeServiceProvider.overrideWith((ref) async => incomeService),
            incomeCategoriesForTransactionProvider.overrideWith(
              (ref) async => <Category>[_category()],
            ),
          ],
          child: _testApp(const HistoryIncomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsOneWidget);
      expect(incomeService.deletedIds, isEmpty);
    });
  });
}
