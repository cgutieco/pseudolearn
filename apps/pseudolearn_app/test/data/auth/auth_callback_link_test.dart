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

    test('a code callback carries no session tokens', () {
      final link = Uri.parse('pseudolearn://auth-callback?code=abc123');
      expect(carriesSessionTokens(link), isFalse);
    });

    test('an empty callback carries no session tokens', () {
      expect(carriesSessionTokens(Uri.parse(authCallbackUrl)), isFalse);
    });

    test('detects an access token in the fragment', () {
      final link = Uri.parse(
        'pseudolearn://auth-callback#access_token=a&expires_in=3600&token_type=bearer',
      );
      expect(carriesSessionTokens(link), isTrue);
    });

    test('detects a refresh token in the query', () {
      final link = Uri.parse('pseudolearn://auth-callback?refresh_token=r');
      expect(carriesSessionTokens(link), isTrue);
    });

    test('detects session tokens next to a code', () {
      final link = Uri.parse('pseudolearn://auth-callback?code=abc#access_token=a');
      expect(carriesSessionTokens(link), isTrue);
    });
  });
}
