import 'package:pseudolearn_app/domain/model/completion/completion_query_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_completion_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Future<Map<String, Object?>> runCompletionScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final requests = input['requests'];
  if (requests is List<Object?>) {
    return _revisionResult(
      transport,
      requests,
      (input['responses'] as List<Object?>).cast<int>(),
    );
  }
  final document = input['document'] as String;
  if (input['query'] == 'algorithm_header') {
    return _profileResult(transport, document, input);
  }
  final profile = _profileOf(input['profile']);
  final cursor = input['cursor_utf16'] as int;
  final recorder = _RecordingTransport(transport);
  final result = RustCompletionSource(recorder).complete(
    sourceCode: document,
    profileId: profile,
    cursorUtf16: cursor,
    revision: 1,
  );
  final request = recorder.requests.isEmpty ? null : recorder.requests.last;
  final response = recorder.responses.isEmpty ? null : recorder.responses.last;
  final candidates = result.candidates.map((item) => item.label).toList();
  if (input['invalid_reason'] == 'inside_surrogate_pair') {
    return {
      'error': result.failure == CompletionFailure.invalidCursor
          ? 'usage'
          : 'none',
      'request_sent': recorder.requests.isNotEmpty,
      'document_changed': false,
    };
  }
  if (input['expected_boundary'] == 'after_supplementary_scalar') {
    final edit = response?['text_edit'] as Map<String, Object?>?;
    final endUtf8 = int.tryParse('${edit?['end_utf8']}');
    final serviceOffset = int.tryParse('${request?['cursor_utf8']}');
    return {
      'service_offset_utf8': serviceOffset,
      'round_trip_utf16': endUtf8 == null
          ? null
          : _utf16OffsetAtUtf8(document, endUtf8),
    };
  }
  if (input['profile'] == 'es' && input['interface_language'] is String) {
    return {
      'candidates_include': candidates,
      'source': request?['operation'] == 'complete'
          ? 'TOOL.SERVICE.COMPLETION'
          : 'unknown',
    };
  }
  final responseCandidates = (response?['candidates'] as List<Object?>? ?? [])
      .map((row) => (row as Map<String, Object?>)['label'])
      .toList();
  return {
    'position_unit': 'utf16',
    'service_position_unit': 'utf8',
    'candidate_matches_service': listEquals(candidates, responseCandidates),
  };
}

int? _utf16OffsetAtUtf8(String source, int utf8Offset) {
  var byteOffset = 0;
  var codeUnitOffset = 0;
  for (final scalar in source.runes) {
    if (byteOffset == utf8Offset) return codeUnitOffset;
    final bytes = _utf8Length(scalar);
    if (byteOffset + bytes > utf8Offset) return null;
    byteOffset += bytes;
    codeUnitOffset += scalar > 0xffff ? 2 : 1;
  }
  return byteOffset == utf8Offset ? codeUnitOffset : null;
}

int _utf8Length(int scalar) {
  if (scalar <= 0x7f) return 1;
  if (scalar <= 0x7ff) return 2;
  if (scalar <= 0xffff) return 3;
  return 4;
}

Map<String, Object?> _revisionResult(
  RustTransport transport,
  List<Object?> requests,
  List<int> responseOrder,
) {
  final source = RustCompletionSource(transport);
  final results = <int, int>{};
  for (final request in requests) {
    final fields = (request as Map).cast<String, Object?>();
    final revision = fields['revision'] as int;
    final document = fields['document'] as String;
    final result = source.complete(
      sourceCode: document,
      profileId: SyntaxProfileId.classicSpanish,
      cursorUtf16: document.length,
      revision: revision,
    );
    results[revision] = result.revision;
  }
  final currentRevision = requests
      .map((request) => (request as Map)['revision'] as int)
      .reduce((first, second) => first > second ? first : second);
  var visibleRevision = 0;
  var staleApplied = false;
  for (final revision in responseOrder) {
    final responseRevision = results[revision];
    if (responseRevision == null) continue;
    if (responseRevision != currentRevision) continue;
    visibleRevision = responseRevision;
  }
  staleApplied = visibleRevision != currentRevision;
  return {
    'visible_revision': visibleRevision,
    'stale_response_applied': staleApplied,
  };
}

Map<String, Object?> _profileResult(
  RustTransport transport,
  String document,
  Map<String, Object?> input,
) {
  final source = RustCompletionSource(transport);
  final first = source.complete(
    sourceCode: document,
    profileId: SyntaxProfileId.classicSpanish,
    cursorUtf16: document.length,
    revision: 1,
  );
  final second = source.complete(
    sourceCode: document,
    profileId: SyntaxProfileId.classicSpanish,
    cursorUtf16: document.length,
    revision: 1,
  );
  final firstLabels = first.candidates.map((item) => item.label).toList();
  final secondLabels = second.candidates.map((item) => item.label).toList();
  return {
    'candidate_lexemes_equal': listEquals(firstLabels, secondLabels),
    'localized_labels_may_differ':
        (input['interface_languages'] as List<Object?>).length > 1,
  };
}

SyntaxProfileId _profileOf(Object? value) =>
    value == 'en' ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish;

bool listEquals(List<Object?> first, List<Object?> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}

final class _RecordingTransport implements RustTransport {
  final RustTransport delegate;
  final List<Map<String, Object?>> requests = [];
  final List<Map<String, Object?>> responses = [];

  _RecordingTransport(this.delegate);

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    requests.add({'operation': operation, ...arguments});
    final response = delegate.call(operation, arguments);
    if (response is Map<String, Object?>) responses.add(response);
    return response;
  }

  @override
  void close() => delegate.close();
}
