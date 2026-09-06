import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/account/account_avatar_identity.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';

AccountSession _session({
  String userId = 'usr_1',
  String? email,
  String? displayName,
}) {
  return AccountSession(
    userId: userId,
    email: email,
    displayName: displayName,
    provider: AuthMethod.apple,
  );
}

void main() {
  group('AccountAvatarIdentity initials', () {
    test('takes the first letter of the first and the last word of a name', () {
      final identity = AccountAvatarIdentity.fromSession(
        _session(displayName: 'César Antonio Gutiérrez Contreras'),
      );

      expect(identity.initials, 'CC');
    });

    test('takes a single letter when the name has one word', () {
      final identity = AccountAvatarIdentity.fromSession(
        _session(displayName: 'Ada'),
      );

      expect(identity.initials, 'A');
    });

    test('ignores repeated separating spaces in a name', () {
      final identity = AccountAvatarIdentity.fromSession(
        _session(displayName: '  Ada   Lovelace  '),
      );

      expect(identity.initials, 'AL');
    });

    test('falls back to the address when there is no name', () {
      final identity = AccountAvatarIdentity.fromSession(
        _session(email: 'ada@example.com'),
      );

      expect(identity.initials, 'A');
    });

    test('yields no initials for an Apple private relay address', () {
      final identity = AccountAvatarIdentity.fromSession(
        _session(email: '7k5fdm5f2j@privaterelay.appleid.com'),
      );

      expect(identity.initials, isNull);
    });

    test('yields no initials when neither name nor address is present', () {
      final identity = AccountAvatarIdentity.fromSession(_session());

      expect(identity.initials, isNull);
    });

    test('yields no initials for an empty or blank name and address', () {
      final blank = AccountAvatarIdentity.fromSession(
        _session(displayName: '   ', email: '   '),
      );

      expect(blank.initials, isNull);
    });

    test('accepts a name written in a script without letter case', () {
      final identity = AccountAvatarIdentity.fromSession(
        _session(displayName: '田中 太郎'),
      );

      expect(identity.initials, '田太');
    });

    test('rejects a name that starts with a digit or a symbol', () {
      final digits = AccountAvatarIdentity.fromSession(
        _session(displayName: '42'),
      );
      final symbols = AccountAvatarIdentity.fromSession(
        _session(displayName: '+34 600'),
      );

      expect(digits.initials, isNull);
      expect(symbols.initials, isNull);
    });

    test('keeps the first initial when the last word is not a letter', () {
      final identity = AccountAvatarIdentity.fromSession(
        _session(displayName: 'Ada 3'),
      );

      expect(identity.initials, 'A');
    });
  });

  group('AccountAvatarIdentity color seed', () {
    test('is stable for the same identifier across invocations', () {
      final first = AccountAvatarIdentity.fromSession(_session(userId: 'usr_789'));
      final second = AccountAvatarIdentity.fromSession(_session(userId: 'usr_789'));

      expect(first.colorSeed, second.colorSeed);
    });

    test('does not depend on the runtime hash of the identifier', () {
      final identity = AccountAvatarIdentity.fromSession(_session(userId: 'ab'));

      expect(identity.colorSeed, 'a'.codeUnitAt(0) * 31 + 'b'.codeUnitAt(0));
    });

    test('is never negative, including for an empty identifier', () {
      final empty = AccountAvatarIdentity.fromSession(_session(userId: ''));
      final long = AccountAvatarIdentity.fromSession(
        _session(userId: 'a' * 512),
      );

      expect(empty.colorSeed, 0);
      expect(long.colorSeed, greaterThanOrEqualTo(0));
    });

    test('separates two different identifiers', () {
      final first = AccountAvatarIdentity.fromSession(_session(userId: 'usr_1'));
      final second = AccountAvatarIdentity.fromSession(_session(userId: 'usr_2'));

      expect(first.colorSeed, isNot(second.colorSeed));
    });
  });
}
