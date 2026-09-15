import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/account/account_state.dart';
import 'package:pseudolearn_app/application/account/local_account_data_purge.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';

void main() {
  const session = AccountSession(userId: 'u', provider: AuthMethod.apple);

  test('a confirmed deletion leaving the deleting state is a local data purge', () {
    expect(
      isLocalAccountDataPurge(const AccountDeletingAccount(session), const AccountUnauthenticated()),
      isTrue,
    );
  });

  test('failed, cancelled or cleanup-failed deletions are not purges', () {
    const deleting = AccountDeletingAccount(session);
    expect(isLocalAccountDataPurge(deleting, const AccountDeletionFailed(session, 'no_connection')), isFalse);
    expect(isLocalAccountDataPurge(deleting, const AccountAuthenticated(session)), isFalse);
    expect(isLocalAccountDataPurge(deleting, const AccountError('local_cleanup_failed')), isFalse);
  });

  test('a plain sign out is not a purge', () {
    expect(
      isLocalAccountDataPurge(const AccountAuthenticated(session), const AccountUnauthenticated()),
      isFalse,
    );
  });
}
