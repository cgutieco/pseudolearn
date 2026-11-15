import 'document_snapshot.dart';

sealed class ReconciliationOutcome {
  const ReconciliationOutcome();
}

final class PushLocal extends ReconciliationOutcome {
  const PushLocal();
}

final class AdoptRemote extends ReconciliationOutcome {
  const AdoptRemote();
}

final class KeepBoth extends ReconciliationOutcome {
  final DocumentSnapshot loser;

  const KeepBoth({required this.loser});
}

final class NoChange extends ReconciliationOutcome {
  const NoChange();
}
