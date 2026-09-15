import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pseudolearn_app/data/auth/native_credential_source.dart';
import 'package:pseudolearn_app/data/auth/supabase_account_deletion_gateway.dart';
import 'package:pseudolearn_app/domain/model/account/account_deletion_outcome.dart';
import 'package:supabase/supabase.dart';

import '../../fakes/fake_native_credential_source.dart';

final class _MemoryPkceStorage extends GotrueAsyncStorage {
  final Map<String, String> entries = {};

  @override
  Future<String?> getItem({required String key}) async => entries[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    entries[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    entries.remove(key);
  }
}

final class _FakeBackend extends http.BaseClient {
  String provider = 'google';
  int functionStatus = 200;
  Object functionBody = const {'status': 'deleted'};
  Object? transportError;
  final List<http.Request> functionRequests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path.endsWith('/token')) {
      return _json(200, _tokenResponse());
    }
    if (request.url.path.endsWith('/functions/v1/$deleteAccountFunctionName')) {
      final error = transportError;
      if (error != null) throw error;
      functionRequests.add(request as http.Request);
      return _json(functionStatus, functionBody);
    }
    return _json(404, {'message': 'unexpected ${request.url}'});
  }

  Map<String, dynamic> _tokenResponse() => {
        'access_token': 'access-token',
        'token_type': 'bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh-token',
        'user': {
          'id': 'usr_1',
          'aud': 'authenticated',
          'email': 'user@example.com',
          'app_metadata': {
            'provider': provider,
            'providers': [provider],
          },
          'user_metadata': <String, dynamic>{},
          'created_at': '2026-01-01T00:00:00Z',
        },
      };

  http.StreamedResponse _json(int status, Object body) {
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      status,
      headers: {'content-type': 'application/json'},
    );
  }

  Map<String, dynamic> get lastFunctionBody {
    final raw = functionRequests.last.body;
    return raw.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
  }
}

const _appleCredential = NativeAppleCredential(
  identityToken: 'apple-identity-token',
  authorizationCode: 'apple-authorization-code',
  rawNonce: 'raw-nonce',
);

void main() {
  group('SupabaseAccountDeletionGateway', () {
    late _FakeBackend backend;
    late SupabaseClient client;
    late FakeNativeCredentialSource credentialSource;
    late SupabaseAccountDeletionGateway gateway;

    setUp(() {
      backend = _FakeBackend();
      client = SupabaseClient(
        'https://fake.supabase.co',
        'fake-anon-key',
        httpClient: backend,
        authOptions: AuthClientOptions(
          autoRefreshToken: false,
          pkceAsyncStorage: _MemoryPkceStorage(),
        ),
      );
      credentialSource = FakeNativeCredentialSource();
      gateway = SupabaseAccountDeletionGateway(
        client: client,
        credentialSource: credentialSource,
      );
    });

    Future<void> signInAs(String provider) async {
      backend.provider = provider;
      await client.auth.signInWithIdToken(
        provider: provider == 'apple' ? OAuthProvider.apple : OAuthProvider.google,
        idToken: 'id-token',
      );
    }

    test('rejects with no_session when nobody is signed in and sends nothing', () async {
      final outcome = await gateway.deleteAccount();

      expect(outcome, isA<AccountDeletionRejected>());
      expect((outcome as AccountDeletionRejected).code, 'no_session');
      expect(backend.functionRequests, isEmpty);
    });

    test('Google account is deleted without opening the Apple sheet', () async {
      await signInAs('google');

      final outcome = await gateway.deleteAccount();

      expect(outcome, isA<AccountDeleted>());
      expect(credentialSource.appleCredentialRequests, 0);
      expect(backend.lastFunctionBody, isEmpty);
      expect(
        backend.functionRequests.single.headers['Authorization'],
        'Bearer access-token',
      );
    });

    test('Apple account sends only the fresh authorization code', () async {
      await signInAs('apple');
      credentialSource.appleCredential = _appleCredential;

      final outcome = await gateway.deleteAccount();

      expect(outcome, isA<AccountDeleted>());
      expect(backend.lastFunctionBody, {
        'apple_authorization_code': 'apple-authorization-code',
      });
    });

    test('cancelled Apple re-authentication never reaches the server', () async {
      await signInAs('apple');
      credentialSource.appleCredential = null;

      final outcome = await gateway.deleteAccount();

      expect(outcome, isA<AccountDeletionCancelled>());
      expect(backend.functionRequests, isEmpty);
    });

    test('Apple native failure is contained as unexpected_failure', () async {
      await signInAs('apple');
      credentialSource.throwError = true;

      final outcome = await gateway.deleteAccount();

      expect((outcome as AccountDeletionRejected).code, 'unexpected_failure');
      expect(backend.functionRequests, isEmpty);
    });

    for (final entry in {
      401: 'unauthorized',
      403: 'apple_identity_mismatch',
      409: 'apple_reauthentication_required',
      500: 'delete_failed',
      502: 'apple_revoke_failed',
    }.entries) {
      test('status ${entry.key} maps to the server code ${entry.value}', () async {
        await signInAs('google');
        backend.functionStatus = entry.key;
        backend.functionBody = {'code': entry.value};

        final outcome = await gateway.deleteAccount();

        expect((outcome as AccountDeletionRejected).code, entry.value);
      });
    }

    test('error body without a code falls back to the HTTP status', () async {
      await signInAs('google');
      backend.functionStatus = 503;
      backend.functionBody = const ['unexpected'];

      final outcome = await gateway.deleteAccount();

      expect((outcome as AccountDeletionRejected).code, 'http_503');
    });

    test('transport failure maps to no connection', () async {
      await signInAs('google');
      backend.transportError = const SocketException('offline');

      final outcome = await gateway.deleteAccount();

      expect(outcome, isA<AccountDeletionNoConnection>());
    });
  });

  group('hasAppleIdentity', () {
    User userWith(Map<String, dynamic> appMetadata, {List<UserIdentity>? identities}) {
      return User(
        id: 'usr',
        appMetadata: appMetadata,
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
        identities: identities,
      );
    }

    test('detects Apple through the providers list even when it is not primary', () {
      expect(hasAppleIdentity(userWith({'provider': 'google', 'providers': ['google', 'apple']})), isTrue);
    });

    test('detects Apple through the linked identities', () {
      final identity = UserIdentity(
        id: 'apple-sub',
        userId: 'usr',
        identityData: const {},
        identityId: 'identity',
        provider: 'apple',
        createdAt: null,
        lastSignInAt: null,
      );
      expect(hasAppleIdentity(userWith({}, identities: [identity])), isTrue);
    });

    test('is false for an email-only account with empty metadata', () {
      expect(hasAppleIdentity(userWith({'provider': 'email'})), isFalse);
      expect(hasAppleIdentity(userWith({})), isFalse);
    });
  });
}
