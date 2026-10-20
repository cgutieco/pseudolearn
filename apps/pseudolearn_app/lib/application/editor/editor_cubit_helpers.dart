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

extension _EditorTypingAssist on EditorCubit {
  SourceEdit? _typingAssist({
    required String newCode,
    required int cursorUtf16,
    required SyntaxProfileId profileId,
    required bool assisted,
  }) {
    if (!assisted && !state.templateActive) return null;
    final typed = assisted
        ? _typedCharacter(state.sourceCode, newCode, cursorUtf16)
        : null;
    return _sourceEditor.afterTyping(
      sourceCode: newCode,
      cursorUtf16: cursorUtf16,
      character: typed ?? '',
      profileId: profileId,
      revision: (state.pendingEdit?.revision ?? 0) + 1,
    );
  }

  String? _typedCharacter(String before, String after, int cursorUtf16) {
    if (after.length != before.length + 1) return null;
    if (cursorUtf16 < 1 || cursorUtf16 > after.length) return null;
    final head = after.substring(0, cursorUtf16 - 1);
    final tail = after.substring(cursorUtf16);
    return before == '$head$tail' ? after[cursorUtf16 - 1] : null;
  }
}
