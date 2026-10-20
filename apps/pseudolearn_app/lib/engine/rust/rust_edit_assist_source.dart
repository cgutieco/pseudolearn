import '../../domain/model/completion/assist_result.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/edit_assist_source.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';
import 'single_text_edit.dart';
import 'source_offset_index.dart';

final class _StaleSession implements Exception {
  const _StaleSession();
}

final class RustEditAssistSource implements EditAssistSource {
  final RustTransport _transport;
  int? _resource;
  int _revision = 0;
  String _text = '';
  SyntaxProfileId? _profile;
  bool _templateActive = false;

  RustEditAssistSource(this._transport);

  @override
  AssistResult? accept({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required CaretRange replacement,
    required String label,
  }) => _guarded(sourceCode, profileId, () {
    final cursor = SourceOffsetIndex(
      _text,
    ).utf8OffsetAtUtf16(replacement.upper);
    if (cursor == null) return null;
    final listing = _call('edit_complete', {'cursor_utf8': '$cursor'});
    final rows = listing['candidates'] as List<Object?>;
    for (final row in rows.cast<Map<String, Object?>>()) {
      if (row['label'] != label) continue;
      return _applyInsertion(_call('edit_accept', {'candidate_id': row['id']}));
    }
    return null;
  });

  @override
  AssistResult? insertTemplate({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required String construction,
    required CaretRange replacement,
  }) => _guarded(sourceCode, profileId, () {
    final offsets = SourceOffsetIndex(_text);
    final start = offsets.utf8OffsetAtUtf16(replacement.lower);
    final end = offsets.utf8OffsetAtUtf16(replacement.upper);
    if (start == null || end == null) return null;
    return _applyInsertion(
      _call('edit_insert_template', {
        'construction': construction,
        'start_utf8': '$start',
        'end_utf8': '$end',
      }),
    );
  });

  @override
  AssistResult? afterTyping({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required int cursorUtf16,
    required String character,
  }) => _guarded(sourceCode, profileId, () {
    final cursor = SourceOffsetIndex(_text).utf8OffsetAtUtf16(cursorUtf16);
    if (cursor == null) return null;
    if (character.isEmpty) return _result(CaretRange.collapsed(cursorUtf16));
    final response = _call('edit_on_type', {
      'cursor_utf8': '$cursor',
      'character': character,
    });
    final edits = (response['edits'] as List<Object?>)
        .cast<Map<String, Object?>>();
    if (edits.isEmpty) {
      _adopt(_text, response);
      return _result(CaretRange.collapsed(cursorUtf16));
    }
    final updated = _applyEdits(edits);
    _adopt(updated, response);
    final caret = SourceOffsetIndex(
      updated,
    ).utf16OffsetAtUtf8(int.parse('${response['cursor_utf8']}'));
    return _result(CaretRange.collapsed(caret ?? updated.length));
  });

  @override
  AssistResult? navigate({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required StopDirection direction,
  }) => _guarded(sourceCode, profileId, () {
    if (!_templateActive) return null;
    final response = _call('edit_navigate_stop', {'direction': direction.name});
    final offsets = SourceOffsetIndex(_text);
    final selection = response['selection'];
    if (selection is Map<String, Object?>) {
      return _result(_range(offsets, selection));
    }
    final exited = response['exited'] as Map<String, Object?>;
    _templateActive = false;
    final caret = offsets.utf16OffsetAtUtf8(
      int.parse('${exited['caret_utf8']}'),
    );
    return _result(CaretRange.collapsed(caret ?? _text.length));
  });

  @override
  void close() => _release();

  AssistResult? _guarded(
    String sourceCode,
    SyntaxProfileId profileId,
    AssistResult? Function() action,
  ) {
    try {
      _synchronize(sourceCode, profileId);
      return action();
    } catch (_) {
      _release();
      return null;
    }
  }

  void _synchronize(String sourceCode, SyntaxProfileId profileId) {
    if (_resource == null || _profile != profileId) {
      _release();
      final opened =
          _transport.call('open_edit_session', {
                'program': sourceCode,
                'profile': rustProfileName(profileId),
                'strictness': rustStrictness,
              })
              as Map<String, Object?>;
      _resource = opened['resource'] as int;
      _revision = int.parse('${opened['revision']}');
      _text = sourceCode;
      _profile = profileId;
      _templateActive = false;
      return;
    }
    final edit = SingleTextEdit.between(_text, sourceCode);
    if (edit == null) return;
    final offsets = SourceOffsetIndex(_text);
    final start = offsets.utf8OffsetAtUtf16(edit.start);
    final end = offsets.utf8OffsetAtUtf16(edit.end);
    if (start == null || end == null) throw const _StaleSession();
    final response = _call('apply_edit', {
      'edits': [
        {'start_utf8': '$start', 'end_utf8': '$end', 'text': edit.replacement},
      ],
    });
    _adopt(sourceCode, response);
  }

  Map<String, Object?> _call(String operation, Map<String, Object?> arguments) {
    final response =
        _transport.call(operation, {
              'resource': _resource,
              'revision': '$_revision',
              ...arguments,
            })
            as Map<String, Object?>;
    if (response.containsKey('stale_revision')) throw const _StaleSession();
    return response;
  }

  void _adopt(String text, Map<String, Object?> response) {
    _text = text;
    _revision = int.parse('${response['revision']}');
    _templateActive = response['template_active'] == true;
  }

  AssistResult _applyInsertion(Map<String, Object?> response) {
    final change = response['edit'] as Map<String, Object?>;
    final updated = _applyEdits([change]);
    _adopt(updated, response);
    final selection = response['selection'] as Map<String, Object?>;
    return _result(_range(SourceOffsetIndex(updated), selection));
  }

  String _applyEdits(List<Map<String, Object?>> edits) {
    final offsets = SourceOffsetIndex(_text);
    var updated = _text;
    for (final change in edits.reversed) {
      final start = offsets.utf16OffsetAtUtf8(
        int.parse('${change['start_utf8']}'),
      );
      final end = offsets.utf16OffsetAtUtf8(int.parse('${change['end_utf8']}'));
      if (start == null || end == null) throw const _StaleSession();
      updated = updated.replaceRange(start, end, change['text'] as String);
    }
    return updated;
  }

  CaretRange _range(SourceOffsetIndex offsets, Map<String, Object?> bounds) {
    final start = offsets.utf16OffsetAtUtf8(
      int.parse('${bounds['start_utf8']}'),
    );
    final end = offsets.utf16OffsetAtUtf8(int.parse('${bounds['end_utf8']}'));
    if (start == null || end == null) throw const _StaleSession();
    return CaretRange(start: start, end: end);
  }

  AssistResult _result(CaretRange selection) => AssistResult(
    sourceCode: _text,
    selection: selection,
    templateActive: _templateActive,
  );

  void _release() {
    final resource = _resource;
    _resource = null;
    _templateActive = false;
    _profile = null;
    if (resource == null) return;
    try {
      _transport.call('release', {'resource': resource});
    } catch (_) {
      return;
    }
  }
}
