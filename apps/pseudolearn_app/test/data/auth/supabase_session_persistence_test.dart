import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pseudolearn_app/data/auth/native_credential_source.dart';
import 'package:pseudolearn_app/data/auth/session_storage.dart';
import 'package:pseudolearn_app/data/auth/supabase_auth_gateway.dart';
import 'package:pseudolearn_app/data/auth/supabase_session_persistence.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:supabase/supabase.dart';

import '../../fakes/fake_native_credential_source.dart';
import '../../fakes/in_memory_session_storage.dart';

String _jwt({required Duration expiresIn, String subject = 'usr_1'}) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final exp = DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  return '${encode({'alg': 'HS256'})}.${encode({'sub': subject, 'exp': exp})}.signature';
}

Map<String, dynamic> _user() => {
      'id': 'usr_1',
      'aud': 'authenticated',
      'email': 'user@example.com',
      'app_metadata': {'provider': 'google', 'providers': ['google']},
      'user_metadata': <String, dynamic>{},
      'created_at': '2026-01-01T00:00:00Z',
    };

final class _AuthServer extends http.BaseClient {
  final List<Uri> tokenRequests = [];
  int refreshStatus = 200;
  Map<String, dynamic> refreshBody = const {};
  Object? refreshTransportError;
  String issuedAccessToken = _jwt(expiresIn: const Duration(hours: 1));

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path.endsWith('/token')) {
      tokenRequests.add(request.url);
      final isRefresh = request.url.queryParameters['grant_type'] == 'refresh_token';
      if (isRefresh) return _refreshResponse();
      return _json(200, _tokenBody());
    }
    if (request.url.path.endsWith('/logout')) return _json(204, const {});
    return _json(404, {'message': 'unexpected ${request.url}'});
  }

  Future<http.StreamedResponse> _refreshResponse() async {
    final error = refreshTransportError;
    if (error != null) throw error;
    if (refreshStatus != 200) return _json(refreshStatus, refreshBody);
    return _json(200, _tokenBody());
  }

  Map<String, dynamic> _tokenBody() => {
        'access_token': issuedAccessToken,
        'token_type': 'bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh-token',
        'user': _user(),
      };

  http.StreamedResponse _json(int status, Map<String, dynamic> body) {
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      status,
      headers: {'content-type': 'application/json'},
    );
  }

  int get refreshCount => tokenRequests
      .where((uri) => uri.queryParameters['grant_type'] == 'refresh_token')
      .length;
}

final class _Device {
  final SupabaseClient client;
  final SupabaseSessionPersistence persistence;
  final SupabaseAuthGateway gateway;

  _Device._(this.client, this.persistence, this.gateway);

  factory _Device.launch(_AuthServer server, SessionStorage storage) {
    final client = SupabaseClient(
      'https://fake.supabase.co',
      'fake-anon-key',
      httpClient: server,
      authOptions: AuthClientOptions(pkceAsyncStorage: _NoPkceStorage()),
    );
    final persistence = SupabaseSessionPersistence(auth: client.auth, storage: storage)
      ..start();
    final credentials = FakeNativeCredentialSource()
      ..googleCredential = const NativeGoogleCredential(idToken: 'google-id-token');
    final gateway = SupabaseAuthGateway(
      client: client,
      sessionPersistence: persistence,
      credentialSource: credentials,
    );
    return _Device._(client, persistence, gateway);
  }

  Future<void> close() async {
    await persistence.stop();
    await client.dispose();
  }
}

final class _NoPkceStorage extends GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> setItem({required String key, required String value}) async {}

  @override
  Future<void> removeItem({required String key}) async {}
}

String _storedSession({required Duration expiresIn}) {
  return jsonEncode({
    'access_token': _jwt(expiresIn: expiresIn),
    'expires_in': 3600,
    'refresh_token': 'stored-refresh-token',
    'token_type': 'bearer',
    'user': _user(),
  });
}

void main() {
  late _AuthServer server;
  late InMemorySessionStorage storage;
  final devices = <_Device>[];

  _Device launch() {
    final device = _Device.launch(server, storage);
    devices.add(device);
    return device;
  }

  setUp(() {
    server = _AuthServer();
    storage = InMemorySessionStorage();
  });

  tearDown(() async {
    for (final device in devices) {
      await device.close();
    }
    devices.clear();
  });

  test('a sign in is written to secure storage with its refresh token', () async {
    final device = launch();

    await device.gateway.signIn(AuthMethod.google);
    await pumpEventQueue();

    final stored = jsonDecode(storage.entries[persistedSessionKey]!) as Map<String, dynamic>;
    expect(stored['refresh_token'], 'refresh-token');
    expect((stored['user'] as Map<String, dynamic>)['id'], 'usr_1');
  });

  test('a cold start restores the stored session without a network refresh', () async {
    await storage.write(persistedSessionKey, _storedSession(expiresIn: const Duration(hours: 1)));
    final device = launch();

    final session = await device.gateway.restoreSession();

    expect(session?.userId, 'usr_1');
    expect(server.refreshCount, 0);
  });

  test('a cold start with an expired access token refreshes and stores the new session', () async {
    await storage.write(persistedSessionKey, _storedSession(expiresIn: const Duration(hours: -1)));
    server.issuedAccessToken = _jwt(expiresIn: const Duration(hours: 2));
    final device = launch();

    final session = await device.gateway.restoreSession();
    await pumpEventQueue();

    expect(session?.userId, 'usr_1');
    expect(server.refreshCount, 1);
    final stored = jsonDecode(storage.entries[persistedSessionKey]!) as Map<String, dynamic>;
    expect(stored['access_token'], server.issuedAccessToken);
  });

  test('a revoked refresh token forgets the stored session', () async {
    await storage.write(persistedSessionKey, _storedSession(expiresIn: const Duration(hours: -1)));
    server.refreshStatus = 400;
    server.refreshBody = {'code': 'refresh_token_not_found', 'message': 'Invalid Refresh Token'};
    final device = launch();

    final session = await device.gateway.restoreSession();
    await pumpEventQueue();

    expect(session, isNull);
    expect(storage.entries.containsKey(persistedSessionKey), isFalse);
  });

  test('a cold start without network keeps the stored session for the next launch', () async {
    await storage.write(persistedSessionKey, _storedSession(expiresIn: const Duration(hours: -1)));
    server.refreshTransportError = const SocketException('offline');
    final device = launch();

    final session = await device.gateway.restoreSession();
    await pumpEventQueue();

    expect(session, isNull);
    expect(storage.entries.containsKey(persistedSessionKey), isTrue);
  });

  test('corrupt stored data is forgotten without throwing', () async {
    for (final corrupt in ['not json', '{}', '{"access_token":"a","token_type":"bearer"}']) {
      await storage.write(persistedSessionKey, corrupt);
      final device = launch();

      final session = await device.gateway.restoreSession();
      await pumpEventQueue();

      expect(session, isNull, reason: corrupt);
      expect(storage.entries.containsKey(persistedSessionKey), isFalse, reason: corrupt);
    }
  });

  test('a first launch with nothing stored returns no session and makes no request', () async {
    final device = launch();

    expect(await device.gateway.restoreSession(), isNull);
    expect(server.tokenRequests, isEmpty);
  });

  test('signing out forgets the stored session', () async {
    final device = launch();
    await device.gateway.signIn(AuthMethod.google);
    await pumpEventQueue();

    await device.gateway.signOut();
    await pumpEventQueue();

    expect(storage.entries.containsKey(persistedSessionKey), isFalse);
  });

  test('a keychain write failure does not break the signed in session', () async {
    storage.throwOnWrite = true;
    final device = launch();

    await device.gateway.signIn(AuthMethod.google);
    await pumpEventQueue();

    expect(await device.gateway.restoreSession(), isNotNull);
    expect(storage.entries, isEmpty);
  });

  test('starting twice keeps a single subscription', () async {
    final device = launch();
    device.persistence.start();

    await device.gateway.signIn(AuthMethod.google);
    await pumpEventQueue();

    expect(storage.entries.containsKey(persistedSessionKey), isTrue);
  });
}
