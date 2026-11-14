import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_union/core/utils/startup_route_provider.dart';
import 'package:pocket_union/ui/router.dart';

void main() {
  group('resolveStartupRoute', () {
    test('sends users without a Supabase session to login', () {
      expect(
        resolveStartupRoute(hasSession: false, coupleId: 'couple-1'),
        AppRoutes.login,
      );
    });

    test('sends authenticated users without a couple to setup', () {
      expect(
        resolveStartupRoute(hasSession: true, coupleId: null),
        AppRoutes.coupleSetup,
      );
    });

    test('sends authenticated users with an empty couple id to setup', () {
      expect(
        resolveStartupRoute(hasSession: true, coupleId: ''),
        AppRoutes.coupleSetup,
      );
    });

    test('sends authenticated users with a couple to home', () {
      expect(
        resolveStartupRoute(hasSession: true, coupleId: 'couple-1'),
        AppRoutes.home,
      );
    });
  });
}
