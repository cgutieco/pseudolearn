import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../platform/platform_native_auth_support.dart';
import 'native_auth_support.dart';
import 'sign_in_nonce.dart';

final class NativeAppleCredential {
  final String identityToken;
  final String authorizationCode;
  final String rawNonce;
  final String? email;
  final String? displayName;

  const NativeAppleCredential({
    required this.identityToken,
    required this.authorizationCode,
    required this.rawNonce,
    this.email,
    this.displayName,
  });
}

final class NativeGoogleCredential {
  final String idToken;
  final String? accessToken;

  const NativeGoogleCredential({
    required this.idToken,
    this.accessToken,
  });
}

abstract interface class NativeCredentialSource {
  bool get isAppleSupported;
  bool get isGoogleSupported;
  Future<NativeAppleCredential?> getAppleCredential();
  Future<NativeGoogleCredential?> getGoogleCredential();
}

final class PlatformNativeCredentialSource implements NativeCredentialSource {
  final GoogleSignIn _googleSignIn;
  final NativeAuthSupport _authSupport;
  bool _initialized = false;

  PlatformNativeCredentialSource({
    GoogleSignIn? googleSignIn,
    NativeAuthSupport? authSupport,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _authSupport = authSupport ?? const PlatformNativeAuthSupport();

  @override
  bool get isAppleSupported => _authSupport.isAppleSupported;

  @override
  bool get isGoogleSupported => _authSupport.isGoogleSupported;

  @override
  Future<NativeAppleCredential?> getAppleCredential() async {
    final nonce = SignInNonce.generate();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce.hashed,
      );
      final idToken = credential.identityToken;
      if (idToken == null) return null;

      return NativeAppleCredential(
        identityToken: idToken,
        authorizationCode: credential.authorizationCode,
        rawNonce: nonce.raw,
        email: credential.email,
        displayName: _fullNameOf(credential),
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<NativeGoogleCredential?> getGoogleCredential() async {
    try {
      if (!_initialized) {
        final clientId = const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
        await _googleSignIn.initialize(
          clientId: clientId.isEmpty ? null : clientId,
        );
        _initialized = true;
      }
      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return null;

      return NativeGoogleCredential(
        idToken: idToken,
      );
    } catch (_) {
      return null;
    }
  }
}

String? _fullNameOf(AuthorizationCredentialAppleID credential) {
  final parts = <String>[];
  final givenName = credential.givenName;
  final familyName = credential.familyName;
  if (givenName != null && givenName.isNotEmpty) parts.add(givenName);
  if (familyName != null && familyName.isNotEmpty) parts.add(familyName);
  return parts.isEmpty ? null : parts.join(' ');
}
