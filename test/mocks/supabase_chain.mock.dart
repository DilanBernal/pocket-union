import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockPostgrestTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

/// Makes an `await` on [transform] resolve to [resolvedValue].
///
/// The service code does `await builder.single()` (or `limit(1)`), and
/// `PostgrestTransformBuilder` implements `Future`, so the `await` is lowered
/// to a call to `.then(callback, onError: ...)`. Stubbing `then` is the only
/// way to control that resolution.
void stubAwaitable(
  MockPostgrestTransformBuilder<dynamic> transform,
  dynamic resolvedValue,
) {
  when<Future<dynamic>>(
    () => transform.then<dynamic>(
      any(),
      onError: any(named: 'onError'),
    ),
  ).thenAnswer((Invocation invocation) async {
    // The callback has a specific parameter type (e.g. `PostgrestMap`), so it
    // cannot be cast to `(dynamic) => dynamic`; invoke it dynamically instead.
    final onValue = invocation.positionalArguments[0];
    return onValue(resolvedValue);
  });
}

/// Builds a fully stubbed Supabase query chain whose terminal call
/// (`.single()`, `.maybeSingle()` or `.limit()`) resolves to [resolvedValue].
///
/// Example:
/// ```dart
/// final chain = createSupabaseChain(<String, dynamic>{'id': 'user-1'});
/// when(() => spClient.from('profile')).thenAnswer((_) => chain);
/// ```
MockSupabaseQueryBuilder createSupabaseChain(dynamic resolvedValue) {
  final builder = MockSupabaseQueryBuilder();
  final filter = MockPostgrestFilterBuilder<PostgrestList>();
  final single = MockPostgrestTransformBuilder<PostgrestMap>();
  final maybeSingle = MockPostgrestTransformBuilder<PostgrestMap?>();
  final limit = MockPostgrestTransformBuilder<PostgrestList>();

  // Filter methods: every call returns the same filter mock (chainable).
  // `thenAnswer` is required instead of `thenReturn` because
  // `PostgrestTransformBuilder` implements `Future` and mocktail rejects
  // returning a Future with `thenReturn`.
  when(() => builder.select(any())).thenAnswer((_) => filter);
  when(() => filter.eq(any(), any())).thenAnswer((_) => filter);
  when(() => filter.filter(any(), any(), any())).thenAnswer((_) => filter);
  when(() => filter.or(any())).thenAnswer((_) => filter);
  when(() => filter.order(any(), ascending: any(named: 'ascending')))
      .thenAnswer((_) => filter);

  // Terminal calls: must always be stubbed, otherwise the `await` on the
  // builder throws (the mock returns null instead of a Future).
  when(() => filter.single()).thenAnswer((_) => single);
  when(() => filter.maybeSingle()).thenAnswer((_) => maybeSingle);
  when(() => filter.limit(any())).thenAnswer((_) => limit);

  stubAwaitable(single, resolvedValue);
  stubAwaitable(maybeSingle, resolvedValue);
  stubAwaitable(limit, resolvedValue);

  return builder;
}
