import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/platform/platform_google_client_ids.dart';

void main() {
  group('googleClientIdsFor', () {
    const apple = 'apple-client.apps.googleusercontent.com';
    const web = 'web-client.apps.googleusercontent.com';

    GoogleClientIds idsFor(String operatingSystem, {String appleClientId = apple, String webClientId = web}) =>
        googleClientIdsFor(operatingSystem, appleClientId: appleClientId, webClientId: webClientId);

    test('Android asks for the web client so Supabase accepts the token audience', () {
      final ids = idsFor('android');

      expect(ids.serverClientId, web);
      expect(ids.clientId, isNull);
    });

    test('iOS and macOS identify themselves with the Apple client', () {
      for (final operatingSystem in ['ios', 'macos']) {
        final ids = idsFor(operatingSystem);

        expect(ids.clientId, apple, reason: operatingSystem);
        expect(ids.serverClientId, isNull, reason: operatingSystem);
      }
    });

    test('Android signs in natively only once the web client is configured', () {
      expect(idsFor('android').isSufficientForNativeSignIn, isTrue);
      expect(idsFor('android', webClientId: '').isSufficientForNativeSignIn, isFalse);
    });

    test('Apple platforms sign in natively even without a build value', () {
      expect(idsFor('ios', appleClientId: '').isSufficientForNativeSignIn, isTrue);
      expect(idsFor('macos').isSufficientForNativeSignIn, isTrue);
    });

    test('an unconfigured value is absent rather than empty', () {
      expect(idsFor('android', webClientId: '').serverClientId, isNull);
      expect(idsFor('ios', appleClientId: '').clientId, isNull);
    });

    test('a platform without native Google sign-in gets no client', () {
      for (final operatingSystem in ['windows', 'linux', '']) {
        final ids = idsFor(operatingSystem);

        expect(ids.clientId, isNull, reason: operatingSystem);
        expect(ids.serverClientId, isNull, reason: operatingSystem);
        expect(ids.isSufficientForNativeSignIn, isFalse, reason: operatingSystem);
      }
    });
  });
}
