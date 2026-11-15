import '../model/account/account_deletion_outcome.dart';

abstract interface class AccountDeletionGateway {
  Future<AccountDeletionOutcome> deleteAccount();
}
