import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/auth/native_auth_support.dart';
import 'package:pseudolearn_app/data/auth/native_credential_source.dart';
import 'package:pseudolearn_app/data/platform/platform_google_client_ids.dart';

final class _StubAuthSupport implements NativeAuthSupport {
  final bool google;

  const _StubAuthSupport({this.google = true});

  @override
  bool get isAppleSupported => false;

  @override
  bool get isGoogleSupported => google;
}

void main() {
  group('PlatformNativeCredentialSource Google support', () {
    PlatformNativeCredentialSource sourceWith(GoogleClientIds ids, {bool platformSupportsGoogle = true}) =>
        PlatformNativeCredentialSource(
          authSupport: _StubAuthSupport(google: platformSupportsGoogle),
          googleClientIds: ids,
        );

    test('a configured Android build signs in with the native account picker', () {
      final source = sourceWith(googleClientIdsFor('android', webClientId: 'web.apps.googleusercontent.com'));

      expect(source.isGoogleSupported, isTrue);
    });

    test('an Android build without the web client falls back to the browser flow', () {
      final source = sourceWith(googleClientIdsFor('android', webClientId: ''));

      expect(source.isGoogleSupported, isFalse);
    });

    test('a platform without native Google support never claims it', () {
      final source = sourceWith(googleClientIdsFor('ios', appleClientId: 'apple'), platformSupportsGoogle: false);

      expect(source.isGoogleSupported, isFalse);
    });
  });
}
