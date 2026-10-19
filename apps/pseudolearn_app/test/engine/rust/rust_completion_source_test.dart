import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_query_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_completion_source.dart';

import '../../fakes/fake_rust_transport.dart';

Map<String, Object?> response({
  String revision = '7',
  String start = '1',
  String end = '5',
}) => {
  'revision': revision,
  'text_edit': {'start_utf8': start, 'end_utf8': end},
  'candidates': [
    {
      'label': 'Mientras',
      'kind': 'Keyword',
      'detail': null,
      'insert_text': 'Mientras',
      'bilingual_origin': null,
    },
  ],
};

void main() {
  group('RustCompletionSource', () {
    test('converts UTF-16 cursors and UTF-8 edit ranges', () {
      late Map<String, Object?> request;
      final transport = FakeRustTransport({
        'complete': (arguments) {
          request = arguments;
          return response();
        },
      });
      final result = RustCompletionSource(transport).complete(
        sourceCode: 'a🧩b',
        profileId: SyntaxProfileId.classicSpanish,
        cursorUtf16: 3,
        revision: 7,
      );
      expect(request['cursor_utf8'], '5');
      expect(request['revision'], '7');
      expect(request['profile'], 'es');
      expect(result.isSuccessful, isTrue);
      expect(result.candidates.single.replacementRange?.start, 1);
      expect(result.candidates.single.replacementRange?.end, 3);
      expect(result.candidates.single.kind, CompletionKind.keyword);
    });

    test('rejects a cursor inside a surrogate pair without calling Rust', () {
      final transport = FakeRustTransport({});
      final result = RustCompletionSource(transport).complete(
        sourceCode: 'a🧩b',
        profileId: SyntaxProfileId.english,
        cursorUtf16: 2,
        revision: 8,
      );
      expect(result.failure, CompletionFailure.invalidCursor);
      expect(transport.calls, isEmpty);
    });

    test('discards a response from a different document revision', () {
      final transport = FakeRustTransport({
        'complete': (_) => response(revision: '6'),
      });
      final result = RustCompletionSource(transport).complete(
        sourceCode: 'word',
        profileId: SyntaxProfileId.english,
        cursorUtf16: 4,
        revision: 7,
      );
      expect(result.failure, CompletionFailure.staleRevision);
      expect(result.candidates, isEmpty);
    });

    test('returns a typed failure when the bridge rejects a query', () {
      final result = RustCompletionSource(FakeRustTransport({})).complete(
        sourceCode: 'word',
        profileId: SyntaxProfileId.english,
        cursorUtf16: 4,
        revision: 7,
      );
      expect(result.failure, CompletionFailure.serviceFailure);
    });
  });
}
