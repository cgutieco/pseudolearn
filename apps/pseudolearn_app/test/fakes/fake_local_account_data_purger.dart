import 'package:pseudolearn_app/domain/ports/local_account_data_purger.dart';

final class FakeLocalAccountDataPurger implements LocalAccountDataPurger {
  bool throwOnPurge = false;
  int purgeCalls = 0;

  @override
  Future<void> purgeAccountData() async {
    purgeCalls++;
    if (throwOnPurge) throw StateError('Simulated purge error');
  }
}
