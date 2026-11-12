import '../../domain/model/analysis/analysis_report.dart';
import '../../domain/model/execution/execution_configuration.dart';
import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/completion/completion_item.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/documents/document_change.dart';
import '../../domain/model/documents/document_command_result.dart';
import '../../domain/model/editor/autosave_policy.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/editor/source_edit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/contextual_completion_source.dart';
import '../../domain/ports/completion_source.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/editor_key_source.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/source_editor.dart';
import '../../domain/ports/text_entry_modality.dart';
import '../library/document_change_follower.dart';
import '../library/use_cases/save_document_source.dart';
import 'editor_state.dart';
part 'editor_cubit_helpers.dart';
part 'editor_source_reveal.dart';

final class EditorCubit extends Cubit<EditorState>
    with
        _EditorDiagnosticSelection,
        _EditorSourceReveal,
        DocumentChangeFollower<EditorState> {
  final DocumentRepository _repository;
  final SaveDocumentSource _saveSource;
  UiLanguageId _languageId = UiLanguageId.spanish;
  final ProgramAnalyzer _analyzer;
  final CompletionSource _completionSource;
  final ContextualCompletionSource? _contextualCompletionSource;
  final EditorKeySource _keySource;
  final SourceEditor _sourceEditor;
  Timer? _autosaveTimer;
  int _completionRevision = 0;
  EditorCubit({
    required DocumentRepository repository,
    required this._analyzer,
    required this._completionSource,
    this._contextualCompletionSource,
    required this._keySource,
    required this._sourceEditor,
    required TextEntryModality textEntry,
    required Clock clock,
  }) : _repository = repository,
       _saveSource = SaveDocumentSource(repository: repository, clock: clock),
       super(EditorState.initial(showsKeyBar: textEntry.hasOnscreenTextEntry)) {
    followDocumentChanges(repository.changes, _onDocumentChanged);
  }
  Future<void> loadDocument(
    String id, {
    UiLanguageId languageId = UiLanguageId.spanish,
  }) async {
    _cancelAutosave();
    _languageId = languageId;
    try {
      final doc = await _repository.loadDocument(id);
      if (doc == null) {
        emit(state.copyWith(errorMessage: 'Document not found'));
        return;
      }
      emit(_loadedDocumentState(doc, languageId));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Error loading document'));
    }
  }

  void updateSourceCode(
    String newCode, {
    int? cursorUtf16,
    UiLanguageId languageId = UiLanguageId.spanish,
    bool assisted = false,
    ExecutionConfiguration? executionConfiguration,
  }) {
    final profileId =
        state.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final cursor = cursorUtf16 ?? newCode.length;
    final assist = _typingAssist(
      newCode: newCode,
      cursorUtf16: cursor,
      profileId: profileId,
      assisted: assisted,
    );
    final code = assist?.sourceCode ?? newCode;
    final changed = assist != null && assist.sourceCode != newCode;
    final revision = _nextCompletionRevision();
    emit(
      _editedDocumentState(
        code: code,
        profileId: profileId,
        languageId: languageId,
        configuration: executionConfiguration,
        assist: assist,
        changed: changed,
        cursor: cursor,
        revision: revision,
      ),
    );
    _scheduleAutosave();
  }

  Future<void> saveDocument() async {
    _cancelAutosave();
    final doc = state.document;
    if (doc == null || !state.isDirty) return;
    emit(state.copyWith(isSaving: true));
    final result = await _saveSource(document: doc, sourceCode: state.sourceCode);
    if (isClosed) return;
    switch (result) {
      case DocumentCommandSucceeded(:final document):
        emit(
          state.copyWith(document: document, isSaving: false, isDirty: false),
        );
      case DocumentCommandRejected():
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: 'Failed to save document',
          ),
        );
    }
  }

  void applyKey(
    EditorKey key,
    CaretRange caret, {
    UiLanguageId languageId = UiLanguageId.spanish,
  }) {
    if (key.kind == EditorKeyKind.completion &&
        (key.revision != state.completionRevision ||
            key.replacementRange == null)) {
      return;
    }
    final profileId =
        state.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final edit = _sourceEditor.applyKey(
      sourceCode: state.sourceCode,
      caret: caret,
      key: key,
      profileId: profileId,
      revision: (state.pendingEdit?.revision ?? 0) + 1,
    );
    emit(_stateAfterKey(edit, profileId, languageId));
    _scheduleAutosave();
  }

  EditorState _stateAfterKey(
    SourceEdit edit,
    SyntaxProfileId profileId,
    UiLanguageId languageId,
  ) {
    final revision = _nextCompletionRevision();
    return state.copyWith(
      sourceCode: edit.sourceCode,
      report: _analyzer.analyze(
        sourceCode: edit.sourceCode,
        profileId: profileId,
        languageId: languageId,
      ),
      contextualCompletions: _queryCompletions(
        sourceCode: edit.sourceCode,
        profileId: profileId,
        cursorUtf16: edit.caret.start,
        revision: revision,
      ),
      completionRevision: revision,
      isDirty: true,
      pendingEdit: edit,
      templateActive: edit.templateActive,
    );
  }

  void updateCompletionCursor(int cursorUtf16) {
    final source = _contextualCompletionSource;
    if (source == null) return;
    final profileId =
        state.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final result = source.complete(
      sourceCode: state.sourceCode,
      profileId: profileId,
      cursorUtf16: cursorUtf16,
      revision: state.completionRevision,
    );
    if (isClosed || result.revision != state.completionRevision) return;
    emit(
      state.copyWith(
        contextualCompletions: result.isSuccessful
            ? result.candidates
            : const [],
      ),
    );
  }

  void _onDocumentChanged(DocumentChange change) {
    if (_isDeletion(change)) {
      emit(state.copyWith(errorMessage: 'Document not found'));
    } else if (_shouldReload(change)) {
      loadDocument(state.document!.id, languageId: _languageId);
    }
  }

  int _nextCompletionRevision() => _completionRevision += 1;
  List<CompletionItem> _queryCompletions({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required int cursorUtf16,
    required int revision,
  }) {
    final source = _contextualCompletionSource;
    if (source == null) return const [];
    final result = source.complete(
      sourceCode: sourceCode,
      profileId: profileId,
      cursorUtf16: cursorUtf16,
      revision: revision,
    );
    if (!result.isSuccessful || result.revision != revision) return const [];
    return result.candidates;
  }

  void _scheduleAutosave() {
    _cancelAutosave();
    _autosaveTimer = Timer(AutosavePolicy.debounce, () {
      if (!isClosed && state.isDirty) {
        saveDocument();
      }
    });
  }

  void _cancelAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
  }
}
