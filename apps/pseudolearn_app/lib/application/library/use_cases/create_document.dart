import '../../../domain/model/documents/document.dart';
import '../../../domain/model/documents/document_command_result.dart';
import '../../../domain/model/documents/document_title_policy.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/ports/clock.dart';
import '../../../domain/ports/document_repository.dart';
import '../../../domain/ports/identifier_generator.dart';

final class CreateDocumentCommand {
  final String title;
  final SyntaxProfileId profileId;
  final String content;
  final String? exerciseId;

  const CreateDocumentCommand({
    required this.title,
    required this.profileId,
    this.content = '',
    this.exerciseId,
  });
}

final class CreateDocument {
  final DocumentRepository _repository;
  final IdentifierGenerator _identifiers;
  final Clock _clock;

  const CreateDocument({
    required this._repository,
    required this._identifiers,
    required this._clock,
  });

  Future<DocumentCommandResult> call(CreateDocumentCommand command) async {
    try {
      final summaries = await _repository.listDocuments();
      final titles = summaries.map((summary) => summary.title);
      if (!isDocumentTitleAvailable(command.title, titles)) {
        return const DocumentCommandRejected(
          DocumentCommandFailure.titleUnavailable,
        );
      }
      final saved = await _repository.saveDocument(_documentFor(command));
      return DocumentCommandSucceeded(saved);
    } catch (_) {
      return const DocumentCommandRejected(DocumentCommandFailure.storageFailed);
    }
  }

  Document _documentFor(CreateDocumentCommand command) {
    final now = _clock.now();
    return Document(
      id: _identifiers.generate(),
      title: normalizeDocumentTitle(command.title),
      content: command.content,
      profileId: command.profileId,
      revision: 1,
      createdAt: now,
      updatedAt: now,
      exerciseId: command.exerciseId,
    );
  }
}
