import 'dart:io';
import 'package:supabase/supabase.dart';
import '../../domain/model/account/account_session.dart';
import '../../domain/model/account/auth_method.dart';
import '../../domain/model/account/auth_outcome.dart';
import '../../domain/ports/auth_gateway.dart';
import 'auth_callback_link.dart';
import 'native_credential_source.dart';

final class SupabaseAuthGateway implements AuthGateway {
  final SupabaseClient _client;
  final NativeCredentialSource _credentialSource;

  SupabaseAuthGateway({
    required SupabaseClient client,
    NativeCredentialSource? credentialSource,
  })  : _client = client,
        _credentialSource =
            credentialSource ?? PlatformNativeCredentialSource();

  @override
  Future<AccountSession?> restoreSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;
      if (session.isExpired) {
        final response = await _client.auth.refreshSession();
        final refreshedSession = response.session;
        if (refreshedSession == null) return null;
        return _mapToAccountSession(refreshedSession);
      }
      return _mapToAccountSession(session);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthOutcome> signIn(AuthMethod method, {String? email}) {
    return _guarded(() async {
      return switch (method) {
        AuthMethod.apple => await _signInWithApple(),
        AuthMethod.google => await _signInWithGoogle(),
        AuthMethod.magicLink => await _signInWithMagicLink(email),
      };
    });
  }

  @override
  Future<AuthOutcome?> completeSignInFromLink(Uri link) async {
    if (!isAuthCallbackLink(link)) return null;
    return _guarded(() async {
      final response = await _client.auth.getSessionFromUrl(link);
      return Authenticated(_mapToAccountSession(response.session));
    });
  }

  Future<AuthOutcome> _guarded(Future<AuthOutcome> Function() attempt) async {
    try {
      return await attempt();
    } on SocketException {
      return const NoConnection();
    } on AuthException catch (error) {
      return Rejected(error.message);
    } catch (error) {
      final message = error.toString();
      if (_isNetworkErrorMessage(message)) {
        return const NoConnection();
      }
      return Rejected(message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  @override
  Stream<AccountSession?> sessionChanges() {
    return _client.auth.onAuthStateChange.map((authState) {
      final session = authState.session;
      if (session == null) return null;
      return _mapToAccountSession(session);
    });
  }

  Future<AuthOutcome> _signInWithApple() async {
    final credential = await _credentialSource.getAppleCredential();
    if (credential == null) return const Cancelled();

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: credential.identityToken,
      nonce: credential.rawNonce,
    );
    final session = response.session;
    if (session == null) {
      return const Rejected(
          'Apple sign-in completed without an active session');
    }
    await _storeAppleFullName(session, credential.displayName);
    return Authenticated(_mapToAccountSession(
      session,
      fallbackProvider: AuthMethod.apple,
      fallbackDisplayName: credential.displayName,
    ));
  }

  Future<void> _storeAppleFullName(Session session, String? fullName) async {
    if (fullName == null) return;
    final metadata = session.user.userMetadata ?? const <String, dynamic>{};
    if (metadata['full_name'] != null) return;
    try {
      await _client.auth
          .updateUser(UserAttributes(data: {'full_name': fullName}));
    } catch (_) {}
  }

  Future<AuthOutcome> _signInWithGoogle() async {
    final credential = await _credentialSource.getGoogleCredential();
    if (credential == null) return const Cancelled();

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: credential.idToken,
      accessToken: credential.accessToken,
    );
    final session = response.session;
    if (session == null) {
      return const Rejected(
          'Google sign-in completed without an active session');
    }
    return Authenticated(
      _mapToAccountSession(session, fallbackProvider: AuthMethod.google),
    );
  }

  Future<AuthOutcome> _signInWithMagicLink(String? email) async {
    if (email == null || email.trim().isEmpty) {
      return const Rejected('Email address is required for magic link');
    }
    await _client.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: authCallbackUrl,
    );
    return MagicLinkSent(email.trim());
  }

  bool _isNetworkErrorMessage(String message) {
    return message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('Failed host lookup');
  }

  AccountSession _mapToAccountSession(
    Session session, {
    AuthMethod? fallbackProvider,
    String? fallbackDisplayName,
  }) {
    final user = session.user;
    final metadata = user.userMetadata ?? const {};
    final displayName = metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        fallbackDisplayName;
    final photoUrl =
        metadata['avatar_url'] as String? ?? metadata['picture'] as String?;
    final providerName = user.appMetadata['provider'] as String?;
    final provider = switch (providerName) {
      'apple' => AuthMethod.apple,
      'google' => AuthMethod.google,
      'email' => AuthMethod.magicLink,
      _ => fallbackProvider ?? AuthMethod.magicLink,
    };

    return AccountSession(
      userId: user.id,
      email: user.email,
      displayName: displayName,
      photoUrl: photoUrl,
      provider: provider,
    );
  }
}
