import 'package:pseudolearn_app/domain/model/account/account_deletion_outcome.dart';
import 'package:pseudolearn_app/domain/ports/account_deletion_gateway.dart';

final class FakeAccountDeletionGateway implements AccountDeletionGateway {
  AccountDeletionOutcome nextOutcome;
  bool throwOnDelete = false;
  int deleteCalls = 0;
  Future<void>? pendingCompletion;

  FakeAccountDeletionGateway({this.nextOutcome = const AccountDeleted()});

  @override
  Future<AccountDeletionOutcome> deleteAccount() async {
    deleteCalls++;
    final pending = pendingCompletion;
    if (pending != null) await pending;
    if (throwOnDelete) throw StateError('Simulated deleteAccount error');
    return nextOutcome;
  }
}
