import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:pocket_union/features/auth/domain/entities/couple_entity.dart';
import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:pocket_union/features/auth/domain/enums/couple_usable_state.dart';
import 'package:pocket_union/features/auth/domain/models/auth_result_model.dart';
import 'package:pocket_union/features/auth/domain/ports/couple_port.dart';
import 'package:pocket_union/features/auth/domain/ports/user_port_local.dart';
import 'package:pocket_union/features/auth/login/dtos/login_dto.dart';
import 'package:pocket_union/features/auth/register/dtos/register_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../mocks/couple_service.mock.dart';
import '../mocks/go_true_client.mock.dart';
import '../mocks/logger.mock.dart';
import '../mocks/shared_preferences_async.dart';
import '../mocks/shared_preferences_cache.dart';
import '../mocks/supabase_chain.mock.dart';
import '../mocks/supabaseClient.mock.dart';
import '../mocks/userDao.mock.dart';

void main() {
  const kEmail = 'some@gmail.com';
  const kPassword = r'P4$$w0rd';
  const kFullName = 'Pepito Alimaña';
  const kUserId = 'user-1';
  const kCoupleId = 'couple-1';

  late SupabaseClient spClient;
  late MockGoTrueClient mockGoTrueClient;
  late UserLocalPort userDao;
  late CouplePort coupleService;
  late SharedPreferencesAsync sharedPreferencesAsync;
  late SharedPreferencesWithCache sharedPreferencesWithCache;
  late AuthService authService;

  setUpAll(() {
    registerFallbackValue(
      UserEntity(id: kUserId, fullName: kFullName, balance: 0, inCloud: true),
    );
    registerFallbackValue(
      CoupleEntity(id: kCoupleId, createdAt: DateTime(2026, 1, 1)),
    );
  });

  setUp(() {
    spClient = MockSupabase();
    mockGoTrueClient = MockGoTrueClient();
    userDao = MockUserDao();
    coupleService = MockCoupleService();
    sharedPreferencesAsync = MockSharedPreferencesAsync();
    sharedPreferencesWithCache = MockSharedPreferencesWithCache();

    when(() => spClient.auth).thenReturn(mockGoTrueClient);
    // when(() => spClient.);

    // All persistence calls must be stubbed: an unstubbed mock returns null
    // and `Future.wait([...])` fails with a type error.
    when(
      () => sharedPreferencesWithCache.setBool(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => sharedPreferencesWithCache.setString(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => sharedPreferencesAsync.setString(any(), any()),
    ).thenAnswer((_) async {});
    when(() => userDao.upsertUser(any())).thenAnswer((_) async => true);

    authService = AuthService(
      userLocalPort: userDao,
      supabaseClient: spClient,
      logger: MockLogger(),
      coupleService: coupleService,
      sharedPreferencesAsync: sharedPreferencesAsync,
      sharedPreferencesWithCache: sharedPreferencesWithCache,
    );
  });

  User buildMockUser({String id = kUserId}) => User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: kEmail,
    createdAt: DateTime.now().toIso8601String(),
  );

  CoupleEntity buildCouple() => CoupleEntity(
    id: kCoupleId,
    createdAt: DateTime(2026, 1, 1),
    user1Id: kUserId,
    isUsable: CoupleUsableState.waiting,
  );

  RegisterDto buildRegisterDto() =>
      RegisterDto(email: kEmail, fullName: kFullName, password: kPassword);

  group('AuthService.register', () {
    test(
      'returns Success and persists user + couple when a couple exists in network',
      () async {
        // Arrange
        when(
          () => mockGoTrueClient.signUp(
            email: kEmail,
            password: kPassword,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => AuthResponse(user: buildMockUser()));
        final couple = buildCouple();
        when(
          () => coupleService.getCoupleByUserIdInNetwork(kUserId),
        ).thenAnswer((_) async => Success<CoupleEntity?>(couple));
        when(
          () => coupleService.syncCoupleAndPartnerLocal(kUserId),
        ).thenAnswer((_) async => Success<CoupleEntity?>(couple));

        // Act
        final result = await authService.register(buildRegisterDto());

        // Assert
        expect(result, isA<Success<AuthResultModel>>());
        expect((result as Success<AuthResultModel>).value.userId, kUserId);
        verify(
          () => mockGoTrueClient.signUp(
            email: kEmail,
            password: kPassword,
            data: any(named: 'data'),
          ),
        ).called(1);
        verify(
          () => coupleService.getCoupleByUserIdInNetwork(kUserId),
        ).called(1);
        verify(
          () => coupleService.syncCoupleAndPartnerLocal(kUserId),
        ).called(1);
        verify(
          () => sharedPreferencesWithCache.setString(
            PreferencesCacheKeys.coupleId,
            kCoupleId,
          ),
        ).called(1);

        final capturedUser =
            verify(() => userDao.upsertUser(captureAny())).captured.single
                as UserEntity;
        expect(capturedUser.fullName, kFullName);
        expect(capturedUser.inCloud, isTrue);
      },
    );

    test(
      'returns Success and creates a couple when none exists in network',
      () async {
        // Arrange
        when(
          () => mockGoTrueClient.signUp(
            email: kEmail,
            password: kPassword,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => AuthResponse(user: buildMockUser()));
        when(
          () => coupleService.getCoupleByUserIdInNetwork(kUserId),
        ).thenAnswer((_) async => const Success<CoupleEntity?>(null));
        final couple = buildCouple();
        when(() => coupleService.createCouple(kUserId)).thenAnswer(
          (_) async => Success<(CoupleEntity, String)>((couple, 'CODE-123')),
        );

        // Act
        final result = await authService.register(buildRegisterDto());

        // Assert
        expect(result, isA<Success<AuthResultModel>>());
        expect((result as Success<AuthResultModel>).value.userId, kUserId);
        verify(() => coupleService.createCouple(kUserId)).called(1);
        verify(
          () => sharedPreferencesWithCache.setString(
            PreferencesCacheKeys.coupleId,
            kCoupleId,
          ),
        ).called(1);
        verifyNever(() => coupleService.upsertCouple(any(), inNetwork: false));
      },
    );
  });

  group('AuthService.login', () {
    test('returns Success and persists session + local profile on valid '
        'credentials', () async {
      // Arrange
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: kEmail,
          password: kPassword,
        ),
      ).thenAnswer((_) async => AuthResponse(user: buildMockUser()));

      // Profile query chain: .from('profile').select(...).filter(...).single()
      final profileChain = createSupabaseChain(<String, dynamic>{
        'id': kUserId,
        'full_name': kFullName,
        'user_balance': 0,
        'last_sync': null,
      });
      // Couple query chain: .from('couple').select(...).or(...).limit(1)
      final coupleChain = createSupabaseChain(<Map<String, dynamic>>[]);
      when(() => spClient.from('profile')).thenAnswer((_) => profileChain);
      when(() => spClient.from('couple')).thenAnswer((_) => coupleChain);

      // Act
      final result = await authService.login(
        LoginDto(email: kEmail, password: kPassword),
      );

      // Assert
      expect(result, isA<Success<AuthResultModel>>());
      expect((result as Success<AuthResultModel>).value.userId, kUserId);
      verify(
        () => mockGoTrueClient.signInWithPassword(
          email: kEmail,
          password: kPassword,
        ),
      ).called(1);
      verify(() => spClient.from('profile')).called(1);
      verify(() => spClient.from('couple')).called(1);
      verify(
        () => sharedPreferencesWithCache.setBool(
          PreferencesCacheKeys.isInSession,
          true,
        ),
      ).called(1);
      verify(
        () => sharedPreferencesWithCache.setString(
          PreferencesCacheKeys.userId,
          kUserId,
        ),
      ).called(1);

      final capturedUser =
          verify(() => userDao.upsertUser(captureAny())).captured.single
              as UserEntity;
      expect(capturedUser.fullName, kFullName);
      expect(capturedUser.inCloud, isTrue);
    });
  });
}
