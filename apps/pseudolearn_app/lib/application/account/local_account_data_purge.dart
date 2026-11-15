import 'account_state.dart';

bool isLocalAccountDataPurge(AccountState previous, AccountState current) {
  return previous is AccountDeletingAccount && current is AccountUnauthenticated;
}
