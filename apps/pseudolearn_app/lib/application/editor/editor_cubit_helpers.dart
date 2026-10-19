part of 'editor_cubit.dart';

extension _EditorDocumentLoading on EditorCubit {
  EditorState _loadedDocumentState(Document document, UiLanguageId languageId) {
    final revision = _nextCompletionRevision();
    return state.copyWith(
      document: document,
      sourceCode: document.content,
      report: _analyzer.analyze(
        sourceCode: document.content,
        profileId: document.profileId,
        languageId: languageId,
      ),
      completions: _completionSource.getCompletions(document.profileId),
      contextualCompletions: _queryCompletions(
        sourceCode: document.content,
        profileId: document.profileId,
        cursorUtf16: document.content.length,
        revision: revision,
      ),
      completionRevision: revision,
      keys: _keySource.keysFor(document.profileId),
      isDirty: false,
      errorMessage: null,
    );
  }
}

mixin _EditorDiagnosticSelection on Cubit<EditorState> {
  void selectDiagnostic(AppDiagnostic? diagnostic) {
    emit(state.copyWith(selectedDiagnostic: diagnostic));
  }
}
