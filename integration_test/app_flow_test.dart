import 'package:integration_test/integration_test.dart';

import 'auth/authentication_flow_test.dart';
import 'features/category/category_flow_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testAuthenticationFlow();
  testCategoryFlow();
}
