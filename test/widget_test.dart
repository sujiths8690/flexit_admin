import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flexit_admin/core/auth/admin_auth_service.dart';
import 'package:flexit_admin/main.dart';
import 'package:flexit_admin/providers/admin_auth/admin_auth_provider.dart';

void main() {
  testWidgets('Flexit app starts on login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminAuthServiceProvider.overrideWithValue(
            AdminAuthService(
              baseUrl: 'http://localhost/api/admin-auth',
              authBaseUrl: 'http://localhost/api/users',
              contentDeviceBaseUrl: 'http://localhost/api/device',
              errorBaseUrl: 'http://localhost/api/user-activity/errors',
              activityBaseUrl: 'http://localhost/api/user-activity',
            ),
          ),
        ],
        child: const FlexitApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('flexit'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
