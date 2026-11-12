import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/presentation/diagram/diagram_empty_state.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, Locale locale, List<String> kinds) =>
    tester.pumpWidget(
      MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DesignCanvas(
            child: DiagramEmptyState(
              notation: DiagramNotation.flowchart,
              hasValidAst: true,
              unsupportedKinds: kinds,
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('an unsupported construct is named in Spanish', (tester) async {
    await _pump(tester, const Locale('es'), ['break_statement']);

    expect(find.textContaining('break_statement'), findsOneWidget);
    expect(find.textContaining('diagrama falso'), findsOneWidget);
  });

  testWidgets('an unsupported construct is named in English', (tester) async {
    await _pump(tester, const Locale('en'), ['defer_statement', 'propagation']);

    expect(find.textContaining('defer_statement, propagation'), findsOneWidget);
    expect(find.textContaining('false diagram'), findsOneWidget);
  });

  testWidgets('without unsupported constructs the usual message remains', (tester) async {
    await _pump(tester, const Locale('en'), const []);

    expect(find.textContaining('false diagram'), findsNothing);
  });

  test('the state exposes the unsupported kinds of the active notation', () {
    const state = DiagramState(
      flowchart: DiagramProgram.unsupported(['break_statement']),
      structogram: DiagramProgram.empty(),
      classDiagram: DiagramScene.empty(),
      hasValidAst: true,
    );

    expect(state.unsupportedKinds, ['break_statement']);
    expect(
      state.copyWith(notation: DiagramNotation.structogram).unsupportedKinds,
      isEmpty,
    );
  });
}
