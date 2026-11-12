import 'package:bloc/bloc.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/documents/document_change.dart';
import '../../domain/model/documents/document_command_result.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/identifier_generator.dart';
import 'document_change_follower.dart';
import 'library_state.dart';
import 'use_cases/create_document.dart';
import 'use_cases/delete_document.dart';
import 'use_cases/list_documents.dart';
import 'use_cases/rename_document.dart';

final class LibraryCubit extends Cubit<LibraryState>
    with DocumentChangeFollower<LibraryState> {
  final ListDocuments _listDocuments;
  final CreateDocument _createDocument;
  final RenameDocument _renameDocument;
  final DeleteDocument _deleteDocument;

  LibraryCubit({
    required DocumentRepository repository,
    required IdentifierGenerator idGenerator,
    required Clock clock,
  }) : _listDocuments = ListDocuments(repository: repository),
       _createDocument = CreateDocument(
         repository: repository,
         identifiers: idGenerator,
         clock: clock,
       ),
       _renameDocument = RenameDocument(repository: repository, clock: clock),
       _deleteDocument = DeleteDocument(repository: repository),
       super(const LibraryState.initial()) {
    followDocumentChanges(repository.changes, _onRepositoryChanged);
  }

  Future<void> loadDocuments() async {
    emit(state.copyWith(status: LibraryStatus.loading));
    await _refresh();
  }

  void searchDocuments(String query) {
    final filtered = _applyFilter(state.allDocuments, query);
    emit(state.copyWith(searchQuery: query, filteredDocuments: filtered));
  }

  Future<Document?> createDocument({
    required String title,
    required SyntaxProfileId profileId,
    String content = '',
    String? exerciseId,
  }) async {
    final result = await _createDocument(
      CreateDocumentCommand(
        title: title,
        profileId: profileId,
        content: content,
        exerciseId: exerciseId,
      ),
    );
    switch (result) {
      case DocumentCommandSucceeded(:final document):
        await loadDocuments();
        return document;
      case DocumentCommandRejected(failure: DocumentCommandFailure.storageFailed):
        emit(state.copyWith(
          status: LibraryStatus.error,
          errorMessage: 'Failed to create document',
        ));
        return null;
      case DocumentCommandRejected():
        return null;
    }
  }

  Future<bool> renameDocument(String id, String newTitle) async {
    final result = await _renameDocument(documentId: id, title: newTitle);
    if (result is! DocumentCommandSucceeded) return false;
    await loadDocuments();
    return true;
  }

  Future<bool> deleteDocument(String id) async {
    if (!await _deleteDocument(id)) return false;
    await loadDocuments();
    return true;
  }

  void _onRepositoryChanged(DocumentChange change) {
    if (state.status == LibraryStatus.success) _refresh();
  }

  Future<void> _refresh() async {
    final documents = await _listDocuments();
    if (isClosed) return;
    if (documents == null) {
      emit(state.copyWith(
        status: LibraryStatus.error,
        errorMessage: 'Failed to load documents',
      ));
      return;
    }
    emit(state.copyWith(
      status: LibraryStatus.success,
      allDocuments: documents,
      filteredDocuments: _applyFilter(documents, state.searchQuery),
      errorMessage: null,
    ));
  }

  List<DocumentSummary> _applyFilter(List<DocumentSummary> list, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return List.of(list);
    return list
        .where((doc) => doc.title.toLowerCase().contains(trimmed))
        .toList();
  }
}
