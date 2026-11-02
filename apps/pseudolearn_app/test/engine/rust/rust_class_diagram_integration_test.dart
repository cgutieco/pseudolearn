import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';
import 'package:pseudolearn_app/presentation/diagram/class_diagram_semantics_layer.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import '../../fakes/recording_rust_transport.dart';

const String _program = '''
interface Readable
method readValue() as integer;
endInterface
class Reader implements Readable
method readValue() as integer
return 7;
endMethod
endClass
class Writer implements Readable
method readValue() as integer
return 8;
endMethod
endClass
algorithm Main
endAlgorithm
''';

const String _pastedDependencies =
    'Importar geo.Punto Como P;\nExportar geo.formas.Circulo;\n'
    'Algoritmo Main\nFinAlgoritmo\n';

void main() {
  testWidgets(
    'native view, scene, source selection and help release each resource',
    (tester) async {
      final native = openNativeTransport();
      addTearDown(native.close);
      final transport = RecordingRustTransport(native);
      final services = buildRustEngineServices(transport);
      final profile = SyntaxProfileId.english;
      final analysis = services.analyzer.analyze(
        sourceCode: _program,
        profileId: profile,
        languageId: UiLanguageId.english,
      );
      expect(analysis.isExecutable, isTrue);

      final view = RustProgramViewSource(transport).loadStructure(
        sourceCode: _program,
        profileId: profile,
        languageId: UiLanguageId.english,
      );
      expect(view?.staticData.realizations, hasLength(2));

      final scene = services.classDiagramBuilder.buildDiagram(
        sourceCode: _program,
        profileId: profile,
      );
      final state = DiagramState(
        flowchart: const DiagramProgram.empty(),
        structogram: const DiagramProgram.empty(),
        classDiagram: scene,
        notation: DiagramNotation.classDiagram,
        hasValidAst: analysis.isExecutable,
      );
      final selected = <SourceRange>[];
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: scene.width,
              height: scene.height,
              child: ClassDiagramSemanticsLayer(
                elements: state.accessibleElements,
                onSourceSelected: selected.add,
              ),
            ),
          ),
        ),
      );
      tester.semantics.tap(
        find.semantics.byLabel('Realization from Reader to Readable'),
      );
      await tester.pump();

      expect(selected, hasLength(1));
      final origin = selected.single;
      expect(
        _program.substring(origin.startOffset, origin.endOffset),
        'class Reader implements Readable\n'
        'method readValue() as integer\n'
        'return 7;\n'
        'endMethod\n'
        'endClass',
      );
      final help = services.syntaxHelpSource.query(
        sourceCode: _program,
        profileId: profile,
        languageId: UiLanguageId.english,
        cursorUtf16: origin.startOffset,
        revision: 17,
      );
      expect(help.outcome, HelpOutcome.help);
      expect(help.revision, 17);
      expect(help.help?.card?.id, 'help.class');
      expect(help.help?.card?.examples, isNotEmpty);
      final openedResources = transport.operations
          .where(
            (operation) =>
                operation == 'create_analysis' ||
                operation == 'open_edit_session',
          )
          .length;
      expect(
        transport.operations
            .where((operation) => operation == 'release')
            .length,
        openedResources,
      );
      handle.dispose();
    },
  );

  test(
    'native failures and repeated revisions leave no open analysis resources',
    () {
      final native = openNativeTransport();
      addTearDown(native.close);
      final transport = RecordingRustTransport(native);
      final services = buildRustEngineServices(transport);
      final profile = SyntaxProfileId.classicSpanish;

      for (var iteration = 0; iteration < 8; iteration++) {
        final report = services.analyzer.analyze(
          sourceCode: 'Clase',
          profileId: profile,
          languageId: UiLanguageId.spanish,
        );
        expect(report.isExecutable, isFalse);
        final scene = services.classDiagramBuilder.buildDiagram(
          sourceCode: 'Clase',
          profileId: profile,
        );
        expect(scene.isEmpty, isTrue);
        final help = services.syntaxHelpSource.query(
          sourceCode: 'Clase',
          profileId: profile,
          languageId: UiLanguageId.spanish,
          cursorUtf16: 2,
          revision: iteration,
        );
        expect(help.outcome, isNot(HelpOutcome.failure));
      }

      final openedResources = transport.operations
          .where(
            (operation) =>
                operation == 'create_analysis' ||
                operation == 'open_edit_session',
          )
          .length;
      expect(
        transport.operations
            .where((operation) => operation == 'release')
            .length,
        openedResources,
      );
    },
  );

  test(
    'native help resolves import, alias and export in both UI languages',
    () {
      final native = openNativeTransport();
      addTearDown(native.close);
      final transport = RecordingRustTransport(native);
      final source = buildRustEngineServices(transport).syntaxHelpSource;
      for (final language in [UiLanguageId.english, UiLanguageId.spanish]) {
        final imported = source.query(
          sourceCode: _pastedDependencies,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: language,
          cursorUtf16: _pastedDependencies.indexOf('Importar') + 2,
          revision: 21,
        );
        final alias = source.query(
          sourceCode: _pastedDependencies,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: language,
          cursorUtf16: _pastedDependencies.indexOf('Como') + 1,
          revision: 22,
        );
        final exported = source.query(
          sourceCode: _pastedDependencies,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: language,
          cursorUtf16: _pastedDependencies.indexOf('Exportar') + 2,
          revision: 23,
        );

        expect(imported.outcome, HelpOutcome.help);
        expect(imported.help?.card?.id, 'help.module-import');
        expect(imported.help?.card?.examples, isNotEmpty);
        expect(alias.outcome, HelpOutcome.help);
        expect(alias.help?.card?.id, 'help.module-import');
        expect(alias.help?.card?.examples, isNotEmpty);
        expect(exported.outcome, HelpOutcome.help);
        expect(exported.help?.card?.id, 'help.module-export');
        expect(exported.help?.card?.examples, isNotEmpty);
      }
      final openedResources = transport.operations
          .where((operation) => operation == 'open_edit_session')
          .length;
      expect(
        transport.operations
            .where((operation) => operation == 'release')
            .length,
        openedResources,
      );
      expect(transport.operations, isNot(contains('execute')));
    },
  );
}
