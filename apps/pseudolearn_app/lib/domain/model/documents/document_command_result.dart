import 'document.dart';

enum DocumentCommandFailure { titleUnavailable, notFound, storageFailed }

sealed class DocumentCommandResult {
  const DocumentCommandResult();
}

final class DocumentCommandSucceeded extends DocumentCommandResult {
  final Document document;

  const DocumentCommandSucceeded(this.document);
}

final class DocumentCommandRejected extends DocumentCommandResult {
  final DocumentCommandFailure failure;

  const DocumentCommandRejected(this.failure);
}
