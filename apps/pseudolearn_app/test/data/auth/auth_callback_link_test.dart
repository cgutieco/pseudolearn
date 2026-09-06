import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/auth/auth_callback_link.dart';

void main() {
  group('auth callback link', () {
    test('the advertised redirect is recognised as the callback', () {
      expect(isAuthCallbackLink(Uri.parse(authCallbackUrl)), isTrue);
    });

    test('recognises the callback carrying an authorization code', () {
      final link = Uri.parse('pseudolearn://auth-callback?code=abc123');
      expect(isAuthCallbackLink(link), isTrue);
    });

    test('recognises the callback carrying an error fragment', () {
      final link = Uri.parse('pseudolearn://auth-callback#error=access_denied');
      expect(isAuthCallbackLink(link), isTrue);
    });

    test('rejects another host under the same scheme', () {
      expect(isAuthCallbackLink(Uri.parse('pseudolearn://document/1')), isFalse);
    });

    test('rejects the same host under another scheme', () {
      expect(isAuthCallbackLink(Uri.parse('https://auth-callback')), isFalse);
    });

    test('rejects a link with neither scheme nor host', () {
      expect(isAuthCallbackLink(Uri.parse('auth-callback')), isFalse);
    });
  });
}
