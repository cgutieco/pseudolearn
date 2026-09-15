import 'dart:async';
import 'dart:convert';
import 'package:supabase/supabase.dart';
import 'session_storage.dart';

const String persistedSessionKey = 'supabase.auth.session';

const Set<AuthChangeEvent> _sessionWritingEvents = {
  AuthChangeEvent.initialSession,
  AuthChangeEvent.signedIn,
  AuthChangeEvent.tokenRefreshed,
  AuthChangeEvent.userUpdated,
};

final class SupabaseSessionPersistence {
  final GoTrueClient _auth;
  final SessionStorage _storage;
  StreamSubscription<AuthState>? _subscription;

  SupabaseSessionPersistence({
    required GoTrueClient auth,
    required SessionStorage storage,
  })  : _auth = auth,
        _storage = storage;

  void start() {
    _subscription ??= _auth.onAuthStateChange.listen(
      (state) => unawaited(_persist(state)),
      onError: (Object _) {},
    );
  }

  Future<Session?> recover() async {
    final stored = await _readStoredSession();
    if (stored == null) return null;
    try {
      final response = await _auth.recoverSession(stored);
      return response.session;
    } on AuthRetryableFetchException {
      return null;
    } on AuthException {
      await _forgetStoredSession();
      return null;
    } on FormatException {
      await _forgetStoredSession();
      return null;
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _persist(AuthState state) async {
    final session = state.session;
    try {
      if (state.event == AuthChangeEvent.signedOut) {
        await _storage.delete(persistedSessionKey);
      } else if (session != null && _sessionWritingEvents.contains(state.event)) {
        await _storage.write(persistedSessionKey, jsonEncode(session.toJson()));
      }
    } on Exception {
      return;
    }
  }

  Future<String?> _readStoredSession() async {
    try {
      return await _storage.read(persistedSessionKey);
    } on Exception {
      return null;
    }
  }

  Future<void> _forgetStoredSession() async {
    try {
      await _storage.delete(persistedSessionKey);
    } on Exception {
      return;
    }
  }
}
