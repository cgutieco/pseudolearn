import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/editor/autosave_policy.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/completion_source.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/editor_key_source.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/source_editor.dart';
import '../../domain/ports/text_entry_modality.dart';
import 'editor_state.dart';

final class EditorCubit extends Cubit<EditorState> {
  final DocumentRepository _repository;
  final ProgramAnalyzer _analyzer;
  final CompletionSource _completionSource;
  final EditorKeySource _keySource;
  final SourceEditor _sourceEditor;
  final Clock _clock;
  Timer? _autosaveTimer;

  EditorCubit({
    required DocumentRepository repository,
    required ProgramAnalyzer analyzer,
    required CompletionSource completionSource,
    required EditorKeySource keySource,
    required SourceEditor sourceEditor,
    required TextEntryModality textEntry,
    required Clock clock,
  })  : _repository = repository,
        _analyzer = analyzer,
        _completionSource = completionSource,
        _keySource = keySource,
        _sourceEditor = sourceEditor,
        _clock = clock,
        super(EditorState.initial(showsKeyBar: textEntry.hasOnscreenTextEntry));

  Future<void> loadDocument(
    String id, {
    UiLanguageId languageId = UiLanguageId.spanish,
  }) async {
    _cancelAutosave();
    try {
      final doc = await _repository.loadDocument(id);
      if (doc == null) {
        emit(state.copyWith(errorMessage: 'Document not found'));
        return;
      }
      final completions = _completionSource.getCompletions(doc.profileId);
      final keys = _keySource.keysFor(doc.profileId);
      final report = _analyzer.analyze(
        sourceCode: doc.content,
        profileId: doc.profileId,
        languageId: languageId,
      );
      emit(state.copyWith(
        document: doc,
        sourceCode: doc.content,
        report: report,
        completions: completions,
        keys: keys,
        isDirty: false,
        errorMessage: null,
      ));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Error loading document'));
    }
  }

  void updateSourceCode(
    String newCode, {
    UiLanguageId languageId = UiLanguageId.spanish,
  }) {
    final profileId = state.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final report = _analyzer.analyze(
      sourceCode: newCode,
      profileId: profileId,
      languageId: languageId,
    );
    emit(state.copyWith(
      sourceCode: newCode,
      report: report,
      isDirty: true,
      selectedDiagnostic: null,
    ));
    _scheduleAutosave();
  }

  Future<void> saveDocument() async {
    _cancelAutosave();
    final doc = state.document;
    if (doc == null || !state.isDirty) return;

    emit(state.copyWith(isSaving: true));
    try {
      final updated = doc.copyWith(
        content: state.sourceCode,
        updatedAt: _clock.now(),
        revision: doc.revision + 1,
      );
      await _repository.saveDocument(updated);
      if (!isClosed) {
        emit(state.copyWith(
          document: updated,
          isSaving: false,
          isDirty: false,
        ));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save document',
        ));
      }
    }
  }

  void applyKey(
    EditorKey key,
    CaretRange caret, {
    UiLanguageId languageId = UiLanguageId.spanish,
  }) {
    final profileId = state.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final edit = _sourceEditor.applyKey(
      sourceCode: state.sourceCode,
      caret: caret,
      key: key,
      profileId: profileId,
      revision: (state.pendingEdit?.revision ?? 0) + 1,
    );
    emit(state.copyWith(
      sourceCode: edit.sourceCode,
      report: _analyzer.analyze(
        sourceCode: edit.sourceCode,
        profileId: profileId,
        languageId: languageId,
      ),
      isDirty: true,
      pendingEdit: edit,
      selectedDiagnostic: null,
    ));
    _scheduleAutosave();
  }

  void selectDiagnostic(AppDiagnostic? diagnostic) {
    emit(state.copyWith(selectedDiagnostic: diagnostic));
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
