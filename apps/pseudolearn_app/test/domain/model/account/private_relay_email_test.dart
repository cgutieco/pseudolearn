import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/account/private_relay_email.dart';

void main() {
  group('isApplePrivateRelayEmail', () {
    test('recognises a relay address', () {
      expect(
        isApplePrivateRelayEmail('7k5fdm5f2j@privaterelay.appleid.com'),
        isTrue,
      );
    });

    test('recognises a relay address regardless of case and padding', () {
      expect(
        isApplePrivateRelayEmail('  ABC@PrivateRelay.AppleID.com  '),
        isTrue,
      );
    });

    test('rejects an ordinary address', () {
      expect(isApplePrivateRelayEmail('ada@example.com'), isFalse);
    });

    test('rejects an address that only mentions the relay domain inside', () {
      expect(
        isApplePrivateRelayEmail('privaterelay.appleid.com@example.com'),
        isFalse,
      );
    });

    test('rejects a null or empty address', () {
      expect(isApplePrivateRelayEmail(null), isFalse);
      expect(isApplePrivateRelayEmail('   '), isFalse);
    });
  });
}
