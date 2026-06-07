import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flexit_admin/main.dart' as app;

const _email = String.fromEnvironment('FLEXIT_ADMIN_EMAIL');
const _password = String.fromEnvironment('FLEXIT_ADMIN_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'admin can login, create, update, and delete an admin',
    (tester) async {
      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final adminEmail = 'codex.it.$suffix@example.com';
      final updatedFirstName = 'CodexUpdated$suffix';

      await app.main();
      await tester.pumpAndSettle();

      await _login(tester);
      await _openAdmins(tester);

      await tester.tap(find.byKey(const ValueKey('admins-add')));
      await tester.pumpAndSettle();

      await _enter(tester, 'add-admin-first-name', 'Codex');
      await _enter(tester, 'add-admin-last-name', 'Integration');
      await _enter(tester, 'add-admin-mobile', '9999999999');
      await _enter(tester, 'add-admin-email', adminEmail);
      await _enter(tester, 'add-admin-age', '30');
      await _enter(tester, 'add-admin-address', 'Integration test address');
      await _enter(tester, 'add-admin-password', 'CodexTest123');
      await _tapAndSettle(
          tester, find.byKey(const ValueKey('add-admin-submit')));

      await _searchAdmin(tester, adminEmail);
      await _tapAndSettle(
          tester, find.byKey(ValueKey('admin-tile-$adminEmail')));

      await _tapAndSettle(
        tester,
        find.byKey(const ValueKey('admin-detail-edit-icon')),
      );
      await _enter(tester, 'edit-admin-first-name', updatedFirstName);
      await _tapAndSettle(
        tester,
        find.byKey(const ValueKey('edit-admin-submit')),
      );
      await _waitFor(tester, find.textContaining(updatedFirstName));

      await _tapAndSettle(
        tester,
        find.byKey(const ValueKey('admin-detail-delete-icon')),
      );
      await _tapAndSettle(tester, find.byKey(const ValueKey('confirm-Delete')));

      await _searchAdmin(tester, adminEmail);
      expect(find.byKey(ValueKey('admin-tile-$adminEmail')), findsNothing);
    },
    skip: _email.isEmpty || _password.isEmpty,
  );
}

Future<void> _login(WidgetTester tester) async {
  final emailField = find.byKey(const ValueKey('admin-login-email'));
  if (emailField.evaluate().isEmpty) return;

  await _enter(tester, 'admin-login-email', _email);
  await _enter(tester, 'admin-login-password', _password);
  await _tapAndSettle(tester, find.byKey(const ValueKey('admin-login-submit')));
  await _waitFor(tester, find.text('Admins'),
      timeout: const Duration(seconds: 60));
}

Future<void> _openAdmins(WidgetTester tester) async {
  final admins = find.text('Admins');
  await _waitFor(tester, admins);
  await _tapAndSettle(tester, admins.first);
  await _waitFor(tester, find.byKey(const ValueKey('admins-add')));
}

Future<void> _searchAdmin(WidgetTester tester, String email) async {
  await _enter(tester, 'admins-search', email);
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.enterText(finder, value);
  await tester.pumpAndSettle();
}

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}
