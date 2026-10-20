import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/editor/source_edit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/device_preferences.dart';
import 'package:pseudolearn_app/domain/ports/source_editor.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/domain/ports/clock.dart';
import 'package:pseudolearn_app/domain/ports/document_repository.dart';
import 'package:pseudolearn_app/domain/ports/text_entry_modality.dart';
import 'see_app_assist_presentation.dart';

Future<Map<String, Object?>> runEditAssistanceScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  if (input['query'] == 'presentation') {
    return runAssistancePresentation(transport, input);
  }
  if (input['query'] == 'default') {
    return {
      'assistance_enabled': const DevicePreferences.defaults().editorAssistance,
    };
  }
  final services = buildRustEngineServices(transport);
  final recorder = _RecordingEditor(services.sourceEditor);
  final cubit = EditorCubit(
    repository: _UnusedRepository(),
    analyzer: services.analyzer,
    completionSource: services.completionSource,
    keySource: services.editorKeySource,
    sourceEditor: recorder,
    textEntry: const _OnscreenEntry(),
    clock: const _FixedClock(),
  );
  final document = input['document'] as String;
  final cursor = input['cursor_utf16'] as int;
  final before = document.replaceRange(cursor - 1, cursor, '');
  cubit.updateSourceCode(before, cursorUtf16: cursor - 1);
  cubit.updateSourceCode(
    document,
    cursorUtf16: cursor,
    assisted: input['assistance_enabled'] == true,
  );
  final changed = cubit.state.sourceCode != document;
  await cubit.close();
  return {
    'on_type_requested': recorder.typedCharacters.contains(input['character']),
    'document_changed': changed,
  };
}

Future<Map<String, Object?>> runAcceptCandidateScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final session = _CandidateSession(transport, input);
  final edit = session.accept();
  if (edit == null) return {'error': 'candidate_not_offered'};
  return {
    'document_after': edit.sourceCode,
    'selection_utf16': [edit.caret.start, edit.caret.end],
  };
}

Future<Map<String, Object?>> runTemplateNavigationScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final session = _CandidateSession(transport, input);
  var edit = session.accept();
  if (edit == null) return {'error': 'candidate_not_offered'};
  final selected = <String>[_selectedText(edit)];
  for (final step in (input['steps'] as List<Object?>).cast<String>()) {
    edit = session.navigate(edit!, step);
    final text = _selectedText(edit);
    if (text.isNotEmpty) selected.add(text);
  }
  return {'selected_texts': selected, 'session_ended': !edit!.templateActive};
}

String _selectedText(SourceEdit edit) =>
    edit.sourceCode.substring(edit.caret.lower, edit.caret.upper);

final class _CandidateSession {
  final RustEngineServices _services;
  final Map<String, Object?> _input;

  _CandidateSession(RustTransport transport, this._input)
    : _services = buildRustEngineServices(transport);

  SyntaxProfileId get _profile => _input['profile'] == 'en'
      ? SyntaxProfileId.english
      : SyntaxProfileId.classicSpanish;

  SourceEdit? accept() {
    final document = _input['document'] as String;
    final result = _services.contextualCompletionSource.complete(
      sourceCode: document,
      profileId: _profile,
      cursorUtf16: _input['cursor_utf16'] as int,
      revision: 1,
    );
    for (final item in result.candidates) {
      if (item.label != _input['candidate']) continue;
      return _services.sourceEditor.applyKey(
        sourceCode: document,
        caret: CaretRange.collapsed(_input['cursor_utf16'] as int),
        key: EditorKey.ofCompletion(item),
        profileId: _profile,
        revision: 1,
      );
    }
    return null;
  }

  SourceEdit navigate(SourceEdit from, String step) {
    final kind = switch (step) {
      'previous' => EditorKeyKind.stopPrevious,
      'exit' => EditorKeyKind.stopExit,
      _ => EditorKeyKind.stopNext,
    };
    return _services.sourceEditor.applyKey(
      sourceCode: from.sourceCode,
      caret: from.caret,
      key: EditorKey.stop(kind),
      profileId: _profile,
      revision: from.revision + 1,
    );
  }
}

final class _RecordingEditor implements SourceEditor {
  final SourceEditor _inner;
  final List<String> typedCharacters = [];

  _RecordingEditor(this._inner);

  @override
  SourceEdit applyKey({
    required String sourceCode,
    required CaretRange caret,
    required EditorKey key,
    required SyntaxProfileId profileId,
    required int revision,
  }) => _inner.applyKey(
    sourceCode: sourceCode,
    caret: caret,
    key: key,
    profileId: profileId,
    revision: revision,
  );

  @override
  SourceEdit? afterTyping({
    required String sourceCode,
    required int cursorUtf16,
    required String character,
    required SyntaxProfileId profileId,
    required int revision,
  }) {
    typedCharacters.add(character);
    return _inner.afterTyping(
      sourceCode: sourceCode,
      cursorUtf16: cursorUtf16,
      character: character,
      profileId: profileId,
      revision: revision,
    );
  }
}

final class _OnscreenEntry implements TextEntryModality {
  const _OnscreenEntry();

  @override
  bool get hasOnscreenTextEntry => false;
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026);
}

final class _UnusedRepository implements DocumentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
