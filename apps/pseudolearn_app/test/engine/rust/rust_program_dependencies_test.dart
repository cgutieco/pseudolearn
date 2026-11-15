import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_dependency.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_read_result.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';

import '../../fakes/native_test_engine.dart';
import '../../fakes/recording_rust_transport.dart';

const String _pasted =
    'Importar geo.Punto Como P;\nExportar geo.formas.Circulo;\n'
    'Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n';

const Set<String> _staticOperations = {
  'create_analysis',
  'create_document',
  'analysis',
  'program_view',
  'release',
  'editor_vocabulary',
};

RustProgramView? _structure(RecordingRustTransport transport, String source) =>
    RustProgramViewSource(
      transport,
    ).loadStructure(sourceCode: source, profileId: SyntaxProfileId.classicSpanish);

void main() {
  tearDownAll(closeTestEngine);

  group('pasted import and export', () {
    test('keep path, alias, kind and the exact source range', () {
      final view = _structure(RecordingRustTransport(testTransport), _pasted)!;

      expect(view.dependencies, hasLength(2));
      final first = view.dependencies.first;
      expect(first.kind, ProgramDependencyKind.importation);
      expect(first.path, ['geo', 'Punto']);
      expect(first.alias, 'P');
      expect(first.status, ProgramDependencyStatus.unlinked);
      expect(first.diagnosticCode, 'moduleSyntaxOutsideProject');
      expect(
        _pasted.substring(first.range.startOffset, first.range.endOffset),
        'Importar geo.Punto Como P;',
      );
      final second = view.dependencies.last;
      expect(second.kind, ProgramDependencyKind.exportation);
      expect(second.qualifiedPath, 'geo.formas.Circulo');
      expect(second.alias, isNull);
    });

    test('leave the remaining units recoverable', () {
      final view = _structure(RecordingRustTransport(testTransport), _pasted)!;

      expect(view.units.map((unit) => unit.name), ['Main']);
    });

    test('are reported by the analyzer as an error that blocks execution', () {
      final report = nativeTestEngine.analyzer.analyze(
        sourceCode: _pasted,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(
        report.diagnostics.map((diagnostic) => diagnostic.code),
        contains('moduleSyntaxOutsideProject'),
      );
      expect(report.hasErrors, isTrue);

      final step = nativeTestEngine.createProgramExecution().startExecution(
        sourceCode: _pasted,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(step.isHalted, isTrue);
      expect(step.isFinished, isFalse);
      expect(step.focus, isNull);
      expect(step.stepNumber, 0);
    });

    test('do not export a partial translation', () {
      for (final target in TargetLanguageId.values) {
        final result = nativeTestEngine.programExporter.export(
          sourceCode: _pasted,
          targetLanguage: target,
          profileId: SyntaxProfileId.classicSpanish,
        );
        expect(result, isA<ExportAnalysisError>());
      }
    });

    test('never touch execution, host, file or network operations', () {
      final transport = RecordingRustTransport(testTransport);
      final services = buildRustEngineServices(transport);

      services.flowchartBuilder.buildDiagram(
        sourceCode: _pasted,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      services.structogramBuilder.buildDiagram(
        sourceCode: _pasted,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      services.classDiagramBuilder.buildDiagram(
        sourceCode: _pasted,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(transport.operations, isNotEmpty);
      expect(
        transport.operations.toSet().difference(_staticOperations),
        isEmpty,
        reason: 'static views may only analyse and read the view',
      );
    });

    test('naming a package that exists on disk grants no read of it', () {
      final transport = RecordingRustTransport(testTransport);
      final view = _structure(
        transport,
        'Importar pseudolearn_app.lib.main;\nAlgoritmo Main\nFinAlgoritmo\n',
      )!;

      expect(view.dependencies.single.status, ProgramDependencyStatus.unlinked);
      expect(
        transport.operations.toSet().difference(_staticOperations),
        isEmpty,
      );
    });
  });

  test('help over a pasted import and alias follows the requested UI language', () {
    final transport = RecordingRustTransport(testTransport);
    final services = buildRustEngineServices(transport);

    final english = services.syntaxHelpSource.query(
      sourceCode: _pasted,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.english,
      cursorUtf16: 3,
      revision: 1,
    );
    final spanish = services.syntaxHelpSource.query(
      sourceCode: _pasted,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      cursorUtf16: _pasted.indexOf('Como') + 1,
      revision: 2,
    );
    final exportEnglish = services.syntaxHelpSource.query(
      sourceCode: _pasted,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.english,
      cursorUtf16: _pasted.indexOf('Exportar') + 2,
      revision: 3,
    );
    final exportSpanish = services.syntaxHelpSource.query(
      sourceCode: _pasted,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      cursorUtf16: _pasted.indexOf('Exportar') + 2,
      revision: 4,
    );

    expect(english.outcome, HelpOutcome.help);
    expect(english.help?.card?.id, 'help.module-import');
    expect(english.help?.card?.title, 'import');
    expect(english.help?.card?.examples, isNotEmpty);
    expect(spanish.outcome, HelpOutcome.help);
    expect(spanish.help?.card?.id, 'help.module-import');
    expect(spanish.help?.card?.title, 'Importar');
    expect(spanish.help?.card?.examples, isNotEmpty);
    expect(exportEnglish.outcome, HelpOutcome.help);
    expect(exportEnglish.help?.card?.id, 'help.module-export');
    expect(exportEnglish.help?.card?.examples, isNotEmpty);
    expect(exportSpanish.outcome, HelpOutcome.help);
    expect(exportSpanish.help?.card?.id, 'help.module-export');
    expect(exportSpanish.help?.card?.examples, isNotEmpty);
    expect(transport.operations, isNot(contains('start')));
    expect(transport.operations, isNot(contains('execute')));
  });

  group('malformed dependencies', () {
    const incomplete = [
      'Importar geo.;\nAlgoritmo Main\nFinAlgoritmo\n',
      'Importar ;\nAlgoritmo Main\nFinAlgoritmo\n',
      'Importar ../secreto;\nAlgoritmo Main\nFinAlgoritmo\n',
      'Importar /etc/passwd;\nAlgoritmo Main\nFinAlgoritmo\n',
    ];

    test('produce no structure instead of an invented one', () {
      for (final source in incomplete) {
        final transport = RecordingRustTransport(testTransport);
        final result = RustProgramViewSource(transport).loadResult(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
          rejects: (diagnostic) => false,
        );
        expect(result, isA<RustProgramViewReadFailure>(), reason: source);
      }
    });

    test('are reported as syntax errors with a readable message', () {
      final report = nativeTestEngine.analyzer.analyze(
        sourceCode: incomplete.first,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(report.hasErrors, isTrue);
      expect(report.diagnostics.first.message, isNotEmpty);
    });
  });

  test('a clean document lists no dependencies', () {
    final view = _structure(
      RecordingRustTransport(testTransport),
      'Algoritmo Main\nFinAlgoritmo\n',
    )!;

    expect(view.dependencies, isEmpty);
  });
}
