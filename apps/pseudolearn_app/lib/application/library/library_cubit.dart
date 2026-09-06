import 'package:bloc/bloc.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/documents/document_title_policy.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/identifier_generator.dart';
import 'library_state.dart';

final class LibraryCubit extends Cubit<LibraryState> {
  final DocumentRepository _repository;
  final IdentifierGenerator _idGenerator;
  final Clock _clock;

  LibraryCubit({
    required DocumentRepository repository,
    required IdentifierGenerator idGenerator,
    required Clock clock,
  })  : _repository = repository,
        _idGenerator = idGenerator,
        _clock = clock,
        super(const LibraryState.initial());

  Future<void> loadDocuments() async {
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      final documents = await _repository.listDocuments();
      final filtered = _applyFilter(documents, state.searchQuery);
      emit(state.copyWith(
        status: LibraryStatus.success,
        allDocuments: documents,
        filteredDocuments: filtered,
        errorMessage: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LibraryStatus.error,
        errorMessage: 'Failed to load documents',
      ));
    }
  }

  void searchDocuments(String query) {
    final filtered = _applyFilter(state.allDocuments, query);
    emit(state.copyWith(
      searchQuery: query,
      filteredDocuments: filtered,
    ));
  }

  Future<Document?> createDocument({
    required String title,
    required SyntaxProfileId profileId,
    String content = '',
    String? exerciseId,
  }) async {
    final summaries = await _repository.listDocuments();
    final existingTitles = summaries.map((s) => s.title);
    if (!isDocumentTitleAvailable(title, existingTitles)) {
      return null;
    }

    try {
      final now = _clock.now();
      final doc = Document(
        id: _idGenerator.generate(),
        title: normalizeDocumentTitle(title),
        content: content,
        profileId: profileId,
        revision: 1,
        createdAt: now,
        updatedAt: now,
        exerciseId: exerciseId,
      );
      await _repository.saveDocument(doc);
      await loadDocuments();
      return doc;
    } catch (_) {
      emit(state.copyWith(
        status: LibraryStatus.error,
        errorMessage: 'Failed to create document',
      ));
      return null;
    }
  }

  Future<bool> renameDocument(String id, String newTitle) async {
    try {
      final doc = await _repository.loadDocument(id);
      if (doc == null) return false;

      final summaries = await _repository.listDocuments();
      final existingTitles = summaries.map((s) => s.title);
      if (!isDocumentTitleAvailable(newTitle, existingTitles, currentTitle: doc.title)) {
        return false;
      }

      final updated = doc.copyWith(
        title: normalizeDocumentTitle(newTitle),
        updatedAt: _clock.now(),
      );
      await _repository.saveDocument(updated);
      await loadDocuments();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      await _repository.deleteDocument(id);
      await loadDocuments();
      return true;
    } catch (_) {
      return false;
    }
  }

  List<DocumentSummary> _applyFilter(
    List<DocumentSummary> list,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return List.of(list);
    return list
        .where((doc) => doc.title.toLowerCase().contains(trimmed))
        .toList();
  }
}
