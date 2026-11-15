import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/account/auth_outcome.dart';

void main() {
  group('AuthOutcome', () {
    const session = AccountSession(
      userId: 'usr_1',
      email: 'test@example.com',
      provider: AuthMethod.apple,
    );

    test('supports value equality for all variants', () {
      expect(const Authenticated(session), equals(const Authenticated(session)));
      expect(const Cancelled(), equals(const Cancelled()));
      expect(const NoConnection(), equals(const NoConnection()));
      expect(const Rejected('invalid_grant'), equals(const Rejected('invalid_grant')));
      expect(const MagicLinkSent('a@b.com'), equals(const MagicLinkSent('a@b.com')));

      expect(const Cancelled(), isNot(equals(const NoConnection())));
      expect(const Rejected('error_a'), isNot(equals(const Rejected('error_b'))));
    });

    test('supports exhaustive pattern matching across all outcomes', () {
      const outcomes = <AuthOutcome>[
        Authenticated(session),
        Cancelled(),
        NoConnection(),
        Rejected('denied'),
        MagicLinkSent('user@example.com'),
      ];

      final descriptions = outcomes.map((outcome) => switch (outcome) {
        Authenticated(:final session) => 'authenticated:${session.userId}',
        Cancelled() => 'cancelled',
        NoConnection() => 'no_connection',
        Rejected(:final reason) => 'rejected:$reason',
        MagicLinkSent(:final email) => 'magic_link:$email',
      }).toList();

      expect(descriptions, [
        'authenticated:usr_1',
        'cancelled',
        'no_connection',
        'rejected:denied',
        'magic_link:user@example.com',
      ]);
    });
  });
}
