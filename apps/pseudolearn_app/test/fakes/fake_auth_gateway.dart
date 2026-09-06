import 'dart:async';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/account/auth_outcome.dart';
import 'package:pseudolearn_app/domain/ports/auth_gateway.dart';

final class FakeAuthGateway implements AuthGateway {
  AccountSession? currentSession;
  AccountSession? get session => currentSession;
  set session(AccountSession? s) => currentSession = s;
  AuthOutcome? nextOutcome;
  bool throwOnSignIn = false;
  bool throwOnRestore = false;
  bool throwOnSignOut = false;
  bool throwOnCompleteFromLink = false;
  AuthOutcome? nextLinkOutcome;
  final _sessionController = StreamController<AccountSession?>.broadcast();

  FakeAuthGateway({this.currentSession, this.nextOutcome});

  void emitSession(AccountSession? session) {
    currentSession = session;
    _sessionController.add(session);
  }

  @override
  Future<AccountSession?> restoreSession() async {
    if (throwOnRestore) throw StateError('Simulated restoreSession error');
    return currentSession;
  }

  @override
  Future<AuthOutcome> signIn(AuthMethod method, {String? email}) async {
    if (throwOnSignIn) throw StateError('Simulated signIn error');
    final outcome = nextOutcome ??
        (currentSession != null
            ? Authenticated(currentSession!)
            : Authenticated(AccountSession(
                userId: 'user_123',
                email: email ?? 'test@example.com',
                displayName: 'Test User',
                provider: method,
              )));
    if (outcome is Authenticated) {
      currentSession = outcome.session;
      _sessionController.add(currentSession);
    }
    return outcome;
  }

  @override
  Future<AuthOutcome?> completeSignInFromLink(Uri link) async {
    if (throwOnCompleteFromLink) throw StateError('Simulated link error');
    final outcome = nextLinkOutcome;
    if (outcome is Authenticated) {
      currentSession = outcome.session;
      _sessionController.add(currentSession);
    }
    return outcome;
  }

  @override
  Future<void> signOut() async {
    if (throwOnSignOut) throw StateError('Simulated signOut error');
    currentSession = null;
    _sessionController.add(null);
  }

  @override
  Stream<AccountSession?> sessionChanges() => _sessionController.stream;

  void dispose() {
    _sessionController.close();
  }
}
