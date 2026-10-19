import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_template_source.dart';

import '../../fakes/fake_rust_transport.dart';

void main() {
  group('RustTemplateSource', () {
    test('requests templates for the selected syntax profile', () {
      late Map<String, Object?> request;
      final transport = FakeRustTransport({
        'completion_templates': (arguments) {
          request = arguments;
          return {
            'templates': [
              {
                'label': 'algorithm',
                'template': 'algorithm name\nendAlgorithm',
                'caret_offset': 10,
                'family': 'structured',
              },
            ],
          };
        },
      });

      final result = RustTemplateSource(
        transport,
      ).getCompletions(SyntaxProfileId.english);

      expect(request['profile'], 'en');
      expect(result.single.label, 'algorithm');
      expect(result.single.template, 'algorithm name\nendAlgorithm');
      expect(result.single.caretOffset, 10);
    });

    test('returns no templates when the service fails', () {
      final result = RustTemplateSource(
        FakeRustTransport({}),
      ).getCompletions(SyntaxProfileId.classicSpanish);

      expect(result, isEmpty);
    });
  });
}
