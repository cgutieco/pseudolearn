sealed class AccountDeletionOutcome {
  const AccountDeletionOutcome();
}

final class AccountDeleted extends AccountDeletionOutcome {
  const AccountDeleted();
}

final class AccountDeletionCancelled extends AccountDeletionOutcome {
  const AccountDeletionCancelled();
}

final class AccountDeletionNoConnection extends AccountDeletionOutcome {
  const AccountDeletionNoConnection();
}

final class AccountDeletionRejected extends AccountDeletionOutcome {
  final String code;

  const AccountDeletionRejected(this.code);
}
