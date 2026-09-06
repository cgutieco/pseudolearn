import '../model/account/account_session.dart';
import '../model/account/auth_method.dart';
import '../model/account/auth_outcome.dart';

abstract interface class AuthGateway {
  Future<AccountSession?> restoreSession();
  Future<AuthOutcome> signIn(AuthMethod method, {String? email});

  Future<AuthOutcome?> completeSignInFromLink(Uri link);
  Future<void> signOut();
  Stream<AccountSession?> sessionChanges();
}
