import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_analysis_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_analyzer.dart';

import '../../fakes/fake_rust_transport.dart';

Map<String, Object?> diagnostic(String severity) => {
  'code': 'c',
  'message': 'm',
  'severity': severity,
  'span': {
    'start': {'line': 1, 'column': 1},
    'end': {'line': 1, 'column': 2},
  },
  'related': <Object?>[],
};

void main() {
  RustProgramAnalyzer analyzerFor(FakeRustTransport transport) =>
      RustProgramAnalyzer(RustAnalysisApi(transport));

  FakeRustTransport transportWith(
    Map<String, Object?> report, [
    List<String>? profiles,
  ]) => FakeRustTransport({
    'create_analysis': (arguments) {
      profiles?.add(arguments['profile']! as String);
      return {'resource': 2, 'document': 1};
    },
    'analysis': (_) => report,
    'release': (_) => null,
  });

  group('RustProgramAnalyzer', () {
    test('a clean tree is executable and resources are released', () {
      final transport = transportWith({
        'tree': true,
        'diagnostics': <Object?>[],
      });
      final report = analyzerFor(transport).analyze(
        sourceCode: 'x',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(report.isExecutable, isTrue);
      expect(report.diagnostics, isEmpty);
      expect(transport.calls.last, 'release');
    });

    test('errors make the program not executable but warnings do not', () {
      final failing =
          analyzerFor(
            transportWith({
              'tree': true,
              'diagnostics': [diagnostic('error')],
            }),
          ).analyze(
            sourceCode: 'x',
            profileId: SyntaxProfileId.english,
            languageId: UiLanguageId.english,
          );
      expect(failing.isExecutable, isFalse);
      expect(failing.diagnostics.single.severity, AppSeverity.error);
      final warned =
          analyzerFor(
            transportWith({
              'tree': true,
              'diagnostics': [diagnostic('warning')],
            }),
          ).analyze(
            sourceCode: 'x',
            profileId: SyntaxProfileId.english,
            languageId: UiLanguageId.english,
          );
      expect(warned.isExecutable, isTrue);
    });

    test('the syntax profile selects the Rust profile', () {
      final profiles = <String>[];
      final analyzer = analyzerFor(
        transportWith({'tree': true, 'diagnostics': <Object?>[]}, profiles),
      );
      for (final profile in SyntaxProfileId.values) {
        analyzer.analyze(
          sourceCode: '',
          profileId: profile,
          languageId: UiLanguageId.system,
        );
      }
      expect(profiles, ['es', 'en']);
    });

    test('the interface language selects the message locale', () {
      final locales = <Object?>[];
      final transport = FakeRustTransport({
        'create_analysis': (arguments) {
          locales.add(arguments['locale']);
          return {'resource': 2, 'document': 1};
        },
        'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
        'release': (_) => null,
      });
      final analyzer = analyzerFor(transport);
      for (final language in UiLanguageId.values) {
        analyzer.analyze(
          sourceCode: '',
          profileId: SyntaxProfileId.classicSpanish,
          languageId: language,
        );
      }
      expect(locales, [null, 'es', 'en']);
    });

    test('resources are released even when the report fails', () {
      final transport = FakeRustTransport({
        'create_analysis': (_) => {'resource': 2, 'document': 1},
        'release': (_) => null,
      });
      expect(
        () => analyzerFor(transport).analyze(
          sourceCode: 'x',
          profileId: SyntaxProfileId.english,
          languageId: UiLanguageId.english,
        ),
        throwsA(anything),
      );
      expect(transport.calls.last, 'release');
    });
  });
}
