import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/bridge/frb_generated.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_analyzer.dart';
import 'package:pseudolearn_app/engine/rust/rust_analysis_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_editor_vocabulary.dart';
import 'package:pseudolearn_app/engine/rust/rust_template_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

void main() {
  RustTransport? transport;
  late RustTemplateSource templates;
  late RustProgramAnalyzer analyzer;

  setUpAll(() async {
    await initializeNativeBridge();
    transport = openNativeTransport();
    templates = RustTemplateSource(transport!);
    analyzer = RustProgramAnalyzer(RustAnalysisApi(transport!));
  });

  tearDownAll(() {
    transport?.close();
    RustLib.dispose();
  });

  Map<String, String> keywords(SyntaxProfileId profile) {
    final words = RustEditorVocabulary(transport!).forProfile(profile)['keywords'] as List<Object?>;
    return {
      for (final pair in words) (pair as List<Object?>)[0] as String: pair[1] as String,
    };
  }

  for (final profile in SyntaxProfileId.values) {
    test('${profile.name} templates are non-empty with valid caret offsets', () {
      final items = templates.getCompletions(profile);

      expect(items, isNotEmpty);
      for (final item in items) {
        expect(item.template, isNotEmpty, reason: item.label);
        expect(item.caretOffset, inInclusiveRange(0, item.template.length), reason: item.label);
      }
    });

    test('${profile.name} templates form programs whose only errors are placeholders', () {
      final language = profile == SyntaxProfileId.english ? UiLanguageId.english : UiLanguageId.spanish;
      final words = keywords(profile);
      final open = words['algorithm']!;
      final close = words['endAlgorithm']!;
      final placeholderErrors = {
        'nonLiteralSwitchCaseLabel',
        'subroutineWithoutReturn',
        'undeclaredVariable',
      };
      for (final item in templates.getCompletions(profile)) {
        final wrappers = [
          item.template,
          '$open Main\n${item.template}\n$close\n',
          '${item.template}\n$open Main\n$close\n',
        ];
        final accepted = wrappers.any((source) {
          final report = analyzer.analyze(
            sourceCode: source,
            profileId: profile,
            languageId: language,
          );
          final errors = report.diagnostics
              .where((d) => d.severity == AppSeverity.error)
              .map((d) => d.code)
              .toSet();
          return errors.difference(placeholderErrors).isEmpty;
        });
        expect(accepted, isTrue, reason: '${profile.name} ${item.label}');
      }
    });
  }
}
