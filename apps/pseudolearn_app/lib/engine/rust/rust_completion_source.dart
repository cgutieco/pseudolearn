import '../../domain/model/completion/completion_item.dart';
import '../../domain/model/completion/completion_query_result.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/contextual_completion_source.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';
import 'source_offset_index.dart';

final class RustCompletionSource implements ContextualCompletionSource {
  final RustTransport _transport;

  const RustCompletionSource(this._transport);

  @override
  CompletionQueryResult complete({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required int cursorUtf16,
    required int revision,
  }) {
    final offsets = SourceOffsetIndex(sourceCode);
    final cursorUtf8 = offsets.utf8OffsetAtUtf16(cursorUtf16);
    if (cursorUtf8 == null) {
      return CompletionQueryResult(
        revision: revision,
        failure: CompletionFailure.invalidCursor,
      );
    }
    try {
      final response =
          _transport.call('complete', {
                'program': sourceCode,
                'profile': rustProfileName(profileId),
                'strictness': 'strict',
                'revision': revision.toString(),
                'cursor_utf8': cursorUtf8.toString(),
              })
              as Map<String, Object?>;
      return _resultOf(response, offsets, revision);
    } catch (_) {
      return CompletionQueryResult(
        revision: revision,
        failure: CompletionFailure.serviceFailure,
      );
    }
  }

  CompletionQueryResult _resultOf(
    Map<String, Object?> response,
    SourceOffsetIndex offsets,
    int revision,
  ) {
    final actualRevision = int.tryParse('${response['revision']}');
    if (actualRevision != revision) {
      return CompletionQueryResult(
        revision: revision,
        failure: CompletionFailure.staleRevision,
      );
    }
    final edit = response['text_edit'];
    if (edit is! Map<String, Object?>) return _failed(revision);
    final startUtf8 = int.tryParse('${edit['start_utf8']}');
    final endUtf8 = int.tryParse('${edit['end_utf8']}');
    if (startUtf8 == null || endUtf8 == null) return _failed(revision);
    final startUtf16 = offsets.utf16OffsetAtUtf8(startUtf8);
    final endUtf16 = offsets.utf16OffsetAtUtf8(endUtf8);
    if (startUtf16 == null || endUtf16 == null || endUtf16 < startUtf16) {
      return _failed(revision);
    }
    final range = CaretRange(start: startUtf16, end: endUtf16);
    final rows = response['candidates'];
    if (rows is! List<Object?>) return _failed(revision);
    final candidates = <CompletionItem>[];
    for (final row in rows) {
      if (row is! Map<String, Object?>) return _failed(revision);
      final candidate = _candidateOf(row, range, revision);
      if (candidate == null) return _failed(revision);
      candidates.add(candidate);
    }
    return CompletionQueryResult(revision: revision, candidates: candidates);
  }

  CompletionItem? _candidateOf(
    Map<String, Object?> row,
    CaretRange range,
    int revision,
  ) {
    final label = row['label'];
    final kind = _kindOf(row['kind']);
    if (label is! String || kind == null) return null;
    final insertion = row['insert_text'] as String? ?? label;
    final family = switch (kind) {
      CompletionKind.classType => CompletionFamily.oop,
      CompletionKind.function ||
      CompletionKind.method => CompletionFamily.procedural,
      _ => CompletionFamily.structured,
    };
    return CompletionItem(
      label: label,
      template: insertion,
      caretOffset: insertion.length,
      family: family,
      kind: kind,
      detail: row['detail'] as String?,
      bilingualOrigin: row['bilingual_origin'] as String?,
      replacementRange: range,
      revision: revision,
    );
  }

  CompletionKind? _kindOf(Object? value) => switch (value) {
    'Keyword' => CompletionKind.keyword,
    'Type' => CompletionKind.type,
    'Variable' => CompletionKind.variable,
    'Function' => CompletionKind.function,
    'Method' => CompletionKind.method,
    'Field' => CompletionKind.field,
    'Class' => CompletionKind.classType,
    'Snippet' => CompletionKind.snippet,
    _ => null,
  };

  CompletionQueryResult _failed(int revision) => CompletionQueryResult(
    revision: revision,
    failure: CompletionFailure.serviceFailure,
  );
}
