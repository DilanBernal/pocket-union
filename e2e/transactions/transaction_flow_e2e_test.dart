import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _e2eEmail = String.fromEnvironment('E2E_TEST_EMAIL');
const _e2ePassword = String.fromEnvironment('E2E_TEST_PASSWORD');
const _e2eCoupleId = String.fromEnvironment('E2E_TEST_COUPLE_ID');
const _supabaseUrl = String.fromEnvironment('SUPABASE_API_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _hasCredentials = _e2eEmail != '' && _e2ePassword != '';

Future<String> _bootstrapRealSession() async {
  if (!Supabase.instance.isInitialized) {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }

  final response = await Supabase.instance.client.auth.signInWithPassword(
    email: _e2eEmail,
    password: _e2ePassword,
  );

  final user = response.user;
  if (user == null) {
    throw Exception('No se pudo autenticar usuario E2E en Supabase');
  }

  var coupleId = _e2eCoupleId;
  if (coupleId.isEmpty) {
    final couples = await Supabase.instance.client
        .from('couple')
        .select('id')
        .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
        .limit(1);

    if (couples is List && couples.isNotEmpty) {
      final first = couples.first as Map<String, dynamic>;
      coupleId = (first['id'] as String?) ?? '';
    }
  }

  if (coupleId.isEmpty) {
    throw Exception(
      'Define E2E_TEST_COUPLE_ID o asocia una pareja al usuario de prueba',
    );
  }

  return coupleId;
}

void testTransactionE2E() {
  final uuid = const Uuid();
  String? coupleId;
  String? createdIncomeId;
  String? createdExpenseId;

  setUpAll(() async {
    if (_e2eEmail.isEmpty || _e2ePassword.isEmpty) return;
    coupleId = await _bootstrapRealSession();
  });

  group('E2E - Transacciones', () {
    test(
      'Entrada: crea ingreso real y valida trigger income_info',
      () async {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final now = DateTime.now().toIso8601String();
        final incomeId = uuid.v4();
        createdIncomeId = incomeId;

        await Supabase.instance.client.from('income').insert({
          'id': incomeId,
          'couple_id': coupleId,
          'name': 'E2E ingreso ${DateTime.now().millisecondsSinceEpoch}',
          'transaction_date': now,
          'description': 'Creado desde suite E2E real',
          'amount': 123450,
          'is_received': true,
          'created_at': now,
          'user_recipient_id': userId,
        });

        final incomeRow = await Supabase.instance.client
            .from('income')
            .select('id, amount')
            .eq('id', incomeId)
            .single();
        expect(incomeRow['id'], incomeId);
        expect(incomeRow['amount'], 123450);

        final infoRow = await Supabase.instance.client
            .from('income_info')
            .select('income_id')
            .eq('income_id', incomeId)
            .single();
        expect(infoRow['income_id'], incomeId);
      },
      skip: !_hasCredentials,
    );

    test(
      'Salida: crea gasto real y valida trigger expense_info',
      () async {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final now = DateTime.now().toIso8601String();
        final expenseId = uuid.v4();
        createdExpenseId = expenseId;

        await Supabase.instance.client.from('expense').insert({
          'id': expenseId,
          'couple_id': coupleId,
          'created_by': userId,
          'name': 'E2E gasto ${DateTime.now().millisecondsSinceEpoch}',
          'transaction_date': now,
          'description': 'Creado desde suite E2E real',
          'amount': 45670,
          'created_at': now,
        });

        final expenseRow = await Supabase.instance.client
            .from('expense')
            .select('id, amount')
            .eq('id', expenseId)
            .single();
        expect(expenseRow['id'], expenseId);
        expect(expenseRow['amount'], 45670);

        final infoRow = await Supabase.instance.client
            .from('expense_info')
            .select('id')
            .eq('id', expenseId)
            .single();
        expect(infoRow['id'], expenseId);
      },
      skip: !_hasCredentials,
    );
  });

  tearDownAll(() async {
    if (!_hasCredentials) return;

    if (createdIncomeId != null) {
      await Supabase.instance.client
          .from('income')
          .delete()
          .eq('id', createdIncomeId!);
    }

    if (createdExpenseId != null) {
      await Supabase.instance.client
          .from('expense')
          .delete()
          .eq('id', createdExpenseId!);
    }

    await Supabase.instance.client.auth.signOut();
  });
}

void main() => testTransactionE2E();
