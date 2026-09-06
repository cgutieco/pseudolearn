import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pseudolearn_app/data/auth/native_credential_source.dart';
import 'package:pseudolearn_app/data/auth/supabase_auth_gateway.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/account/auth_outcome.dart';
import 'package:supabase/supabase.dart';

final class FakeNativeCredentialSource implements NativeCredentialSource {
  NativeAppleCredential? appleCredential;
  NativeGoogleCredential? googleCredential;
  bool throwError = false;

  @override
  Future<NativeAppleCredential?> getAppleCredential() async {
    if (throwError) throw Exception('Apple native failure');
    return appleCredential;
  }

  @override
  Future<NativeGoogleCredential?> getGoogleCredential() async {
    if (throwError) throw Exception('Google native failure');
    return googleCredential;
  }
}

final class InMemoryPkceStorage extends GotrueAsyncStorage {
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

final class RecordedRequest {
  final String method;
  final Uri url;
  final Map<String, dynamic> body;

  const RecordedRequest({
    required this.method,
    required this.url,
    required this.body,
  });
}

final class FakeAuthServer extends http.BaseClient {
  final List<RecordedRequest> requests = [];
  Map<String, dynamic> userMetadata = <String, dynamic>{};
  int updateUserStatus = 200;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final rawBody = request is http.Request ? request.body : '';
    requests.add(RecordedRequest(
      method: request.method,
      url: request.url,
      body: rawBody.isEmpty
          ? const <String, dynamic>{}
          : jsonDecode(rawBody) as Map<String, dynamic>,
    ));

    if (request.url.path.endsWith('/otp')) {
      return _jsonResponse(200, const <String, dynamic>{});
    }
    if (request.url.path.endsWith('/token')) {
      return _jsonResponse(200, {
        'access_token': 'access-token',
        'token_type': 'bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh-token',
        'user': _user(),
      });
    }
    if (request.url.path.endsWith('/user')) {
      if (updateUserStatus != 200) {
        return _jsonResponse(updateUserStatus, {'message': 'update rejected'});
      }
      final data = requests.last.body['data'] as Map<String, dynamic>?;
      userMetadata = data ?? userMetadata;
      return _jsonResponse(200, _user());
    }
    return _jsonResponse(404, {'message': 'unexpected ${request.url}'});
  }

  Map<String, dynamic> _user() => {
        'id': 'usr_apple',
        'aud': 'authenticated',
        'email': '7k5fdm5f2j@privaterelay.appleid.com',
        'app_metadata': {'provider': 'apple'},
        'user_metadata': userMetadata,
        'created_at': '2026-01-01T00:00:00Z',
      };

  http.StreamedResponse _jsonResponse(int status, Map<String, dynamic> body) {
    final bytes = utf8.encode(jsonEncode(body));
    return http.StreamedResponse(
      Stream.value(bytes),
      status,
      headers: {'content-type': 'application/json'},
    );
  }

  List<RecordedRequest> get userUpdates {
    final updates = <RecordedRequest>[];
    for (final request in requests) {
      if (request.url.path.endsWith('/user') && request.method == 'PUT') {
        updates.add(request);
      }
    }
    return updates;
  }

  RecordedRequest get tokenRequest {
    for (final request in requests) {
      if (request.url.path.endsWith('/token')) return request;
    }
    throw StateError('No token request was issued');
  }
}

void main() {
  group('SupabaseAuthGateway', () {
    late FakeAuthServer server;
    late InMemoryPkceStorage pkceStorage;
    late SupabaseClient client;
    late FakeNativeCredentialSource credentialSource;
    late SupabaseAuthGateway gateway;

    setUp(() {
      server = FakeAuthServer();
      pkceStorage = InMemoryPkceStorage();
      client = SupabaseClient(
        'https://fake.supabase.co',
        'fake-anon-key',
        httpClient: server,
        authOptions: AuthClientOptions(
          autoRefreshToken: false,
          pkceAsyncStorage: pkceStorage,
        ),
      );
      credentialSource = FakeNativeCredentialSource();
      gateway = SupabaseAuthGateway(
        client: client,
        credentialSource: credentialSource,
      );
    });

    test('restoreSession returns null when no session is present', () async {
      final session = await gateway.restoreSession();
      expect(session, isNull);
    });

    test('signIn with Apple returns Cancelled when credential source returns null', () async {
      credentialSource.appleCredential = null;
      final outcome = await gateway.signIn(AuthMethod.apple);
      expect(outcome, isA<Cancelled>());
    });

    test('signIn with Apple returns Rejected when native credential source throws', () async {
      credentialSource.throwError = true;
      final outcome = await gateway.signIn(AuthMethod.apple);
      expect(outcome, isA<Rejected>());
    });

    test('signIn with Apple forwards the raw nonce to the token exchange', () async {
      credentialSource.appleCredential = const NativeAppleCredential(
        identityToken: 'apple-identity-token',
        rawNonce: 'raw-nonce-value',
      );

      await gateway.signIn(AuthMethod.apple);

      expect(server.tokenRequest.body['nonce'], 'raw-nonce-value');
      expect(server.tokenRequest.body['provider'], 'apple');
      expect(server.tokenRequest.body['id_token'], 'apple-identity-token');
    });

    test('signIn with Apple stores the full name the first authorization returns', () async {
      credentialSource.appleCredential = const NativeAppleCredential(
        identityToken: 'apple-identity-token',
        rawNonce: 'raw-nonce-value',
        displayName: 'Ada Lovelace',
      );

      final outcome = await gateway.signIn(AuthMethod.apple);

      expect(server.userUpdates, hasLength(1));
      expect(
        (server.userUpdates.single.body['data'] as Map<String, dynamic>)['full_name'],
        'Ada Lovelace',
      );
      expect(outcome, isA<Authenticated>());
      expect((outcome as Authenticated).session.displayName, 'Ada Lovelace');
      expect(outcome.session.provider, AuthMethod.apple);
    });

    test('signIn with Apple does not overwrite a full name already stored', () async {
      server.userMetadata = {'full_name': 'Ada King'};
      credentialSource.appleCredential = const NativeAppleCredential(
        identityToken: 'apple-identity-token',
        rawNonce: 'raw-nonce-value',
        displayName: 'Ada Lovelace',
      );

      final outcome = await gateway.signIn(AuthMethod.apple);

      expect(server.userUpdates, isEmpty);
      expect((outcome as Authenticated).session.displayName, 'Ada King');
    });

    test('signIn with Apple skips the update when Apple sends no name', () async {
      credentialSource.appleCredential = const NativeAppleCredential(
        identityToken: 'apple-identity-token',
        rawNonce: 'raw-nonce-value',
      );

      final outcome = await gateway.signIn(AuthMethod.apple);

      expect(server.userUpdates, isEmpty);
      expect((outcome as Authenticated).session.displayName, isNull);
      expect(outcome.session.email, '7k5fdm5f2j@privaterelay.appleid.com');
    });

    test('signIn with Apple still authenticates when storing the name fails', () async {
      server.updateUserStatus = 500;
      credentialSource.appleCredential = const NativeAppleCredential(
        identityToken: 'apple-identity-token',
        rawNonce: 'raw-nonce-value',
        displayName: 'Ada Lovelace',
      );

      final outcome = await gateway.signIn(AuthMethod.apple);

      expect(outcome, isA<Authenticated>());
      expect((outcome as Authenticated).session.displayName, 'Ada Lovelace');
    });

    test('signIn with Google returns Cancelled when credential source returns null', () async {
      credentialSource.googleCredential = null;
      final outcome = await gateway.signIn(AuthMethod.google);
      expect(outcome, isA<Cancelled>());
    });

    test('signIn with Google returns Rejected when native credential source throws', () async {
      credentialSource.throwError = true;
      final outcome = await gateway.signIn(AuthMethod.google);
      expect(outcome, isA<Rejected>());
    });

    test('signIn with Google exchanges the identity token without a nonce', () async {
      credentialSource.googleCredential = const NativeGoogleCredential(
        idToken: 'google-identity-token',
        accessToken: 'google-access-token',
      );

      final outcome = await gateway.signIn(AuthMethod.google);

      expect(server.tokenRequest.body['provider'], 'google');
      expect(server.tokenRequest.body['access_token'], 'google-access-token');
      expect(server.tokenRequest.body['nonce'], isNull);
      expect(server.userUpdates, isEmpty);
      expect(outcome, isA<Authenticated>());
    });

    test('signIn with Magic Link rejects empty or null email without calling client', () async {
      final nullOutcome = await gateway.signIn(AuthMethod.magicLink, email: null);
      expect(nullOutcome, isA<Rejected>());

      final emptyOutcome = await gateway.signIn(AuthMethod.magicLink, email: '   ');
      expect(emptyOutcome, isA<Rejected>());
      expect(server.requests, isEmpty);
    });

    test('signIn with Magic Link asks the backend to redirect to the application callback', () async {
      final outcome = await gateway.signIn(
        AuthMethod.magicLink,
        email: '  ada@example.com  ',
      );

      expect(outcome, equals(const MagicLinkSent('ada@example.com')));
      final request = server.requests.single;
      expect(request.url.path, endsWith('/otp'));
      expect(request.url.queryParameters['redirect_to'], 'pseudolearn://auth-callback');
      expect(request.body['code_challenge'], isNotNull);
      expect(request.body['email'], 'ada@example.com');
    });

    test('completeSignInFromLink ignores a link that is not the authentication callback', () async {
      final outcome = await gateway.completeSignInFromLink(
        Uri.parse('pseudolearn://document/doc_1'),
      );

      expect(outcome, isNull);
      expect(server.requests, isEmpty);
    });

    test('completeSignInFromLink exchanges the callback code for a session', () async {
      await gateway.signIn(AuthMethod.magicLink, email: 'ada@example.com');
      server.requests.clear();

      final outcome = await gateway.completeSignInFromLink(
        Uri.parse('pseudolearn://auth-callback?code=authorization-code'),
      );

      expect(server.tokenRequest.url.queryParameters['grant_type'], 'pkce');
      expect(server.tokenRequest.body['auth_code'], 'authorization-code');
      expect(outcome, isA<Authenticated>());
      expect((outcome! as Authenticated).session.userId, 'usr_apple');
      expect(pkceStorage.entries, isEmpty);
    });

    test('completeSignInFromLink rejects a callback that carries an error', () async {
      final outcome = await gateway.completeSignInFromLink(
        Uri.parse('pseudolearn://auth-callback#error=access_denied'
            '&error_code=otp_expired'
            '&error_description=Email+link+is+invalid+or+has+expired'),
      );

      expect(outcome, isA<Rejected>());
      expect((outcome! as Rejected).reason, contains('expired'));
      expect(server.requests, isEmpty);
    });

    test('completeSignInFromLink rejects a callback without a code', () async {
      final outcome = await gateway.completeSignInFromLink(
        Uri.parse('pseudolearn://auth-callback'),
      );

      expect(outcome, isA<Rejected>());
      expect(server.requests, isEmpty);
    });

    test('completeSignInFromLink rejects a code with no verifier stored on this device', () async {
      final outcome = await gateway.completeSignInFromLink(
        Uri.parse('pseudolearn://auth-callback?code=authorization-code'),
      );

      expect(outcome, isA<Rejected>());
      expect(server.requests, isEmpty);
    });

    test('signOut completes without error even if not logged in', () async {
      await expectLater(gateway.signOut(), completes);
    });

    test('sessionChanges stream emits without throwing', () async {
      final stream = gateway.sessionChanges();
      expect(stream, isNotNull);
    });
  });
}
