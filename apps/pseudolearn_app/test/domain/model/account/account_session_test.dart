import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';

void main() {
  group('AccountSession', () {
    test('supports value equality with all fields populated', () {
      const sessionA = AccountSession(
        userId: 'usr_1',
        email: 'ada@example.com',
        displayName: 'Ada Lovelace',
        photoUrl: 'https://example.com/ada.png',
        provider: AuthMethod.apple,
      );
      const sessionB = AccountSession(
        userId: 'usr_1',
        email: 'ada@example.com',
        displayName: 'Ada Lovelace',
        photoUrl: 'https://example.com/ada.png',
        provider: AuthMethod.apple,
      );

      expect(sessionA, equals(sessionB));
      expect(sessionA.hashCode, equals(sessionB.hashCode));
    });

    test('supports value equality with optional fields null', () {
      const sessionA = AccountSession(
        userId: 'usr_2',
        provider: AuthMethod.google,
      );
      const sessionB = AccountSession(
        userId: 'usr_2',
        provider: AuthMethod.google,
      );

      expect(sessionA, equals(sessionB));
      expect(sessionA.email, isNull);
      expect(sessionA.displayName, isNull);
      expect(sessionA.photoUrl, isNull);
    });

    test('differentiates instances with different properties', () {
      const sessionA = AccountSession(
        userId: 'usr_1',
        provider: AuthMethod.apple,
      );
      const sessionB = AccountSession(
        userId: 'usr_2',
        provider: AuthMethod.apple,
      );
      const sessionC = AccountSession(
        userId: 'usr_1',
        provider: AuthMethod.magicLink,
      );

      expect(sessionA, isNot(equals(sessionB)));
      expect(sessionA, isNot(equals(sessionC)));
    });
  });
}
