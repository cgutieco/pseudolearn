import '../../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

void main() {
  group('RustProfileCompletionSource', () {
    final source = nativeTestEngine.completionSource;

    test('returns completion templates for classic spanish profile', () {
      final items = source.getCompletions(SyntaxProfileId.classicSpanish);
      expect(items, isNotEmpty);
      expect(
        items.any((item) => item.label.toLowerCase().contains('si')),
        isTrue,
      );
      expect(
        items.any((item) => item.label.toLowerCase().contains('mientras')),
        isTrue,
      );
      expect(
        items.any((item) => item.family == CompletionFamily.structured),
        isTrue,
      );
    });

    test('returns completion templates for english profile', () {
      final items = source.getCompletions(SyntaxProfileId.english);
      expect(items, isNotEmpty);
      expect(
        items.any((item) => item.label.toLowerCase().contains('if')),
        isTrue,
      );
      expect(
        items.any((item) => item.label.toLowerCase().contains('while')),
        isTrue,
      );
    });
  });
}
