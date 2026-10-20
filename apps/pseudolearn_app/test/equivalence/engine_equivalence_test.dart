import 'package:flutter_test/flutter_test.dart';
import '../fakes/native_test_engine.dart';
import '../../tool/content/knowledge_validation.dart';
import 'dart:io';
import 'equivalence_corpus.dart';

void main() {
  test('every pedagogical example and solution analyzes through Rust', () {
    final programs = [...exampleCorpus(), ...exerciseSolutionCorpus()];
    expect(programs, isNotEmpty);
    for (final program in programs) {
      final report = nativeTestEngine.analyzer.analyze(
        sourceCode: program.source,
        profileId: program.profile,
        languageId: program.language,
      );
      expect(report.hasErrors, isFalse, reason: program.name);
    }
  });

  test(
    'the knowledge corpus satisfies execution and structural contracts',
    () async {
      final errors = await validateKnowledge(Directory('assets/knowledge'));
      expect(errors, isEmpty);
    },
  );
}
