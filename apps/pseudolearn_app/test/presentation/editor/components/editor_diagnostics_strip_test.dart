import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_diagnostics_strip.dart';
import 'package:pseudolearn_app/presentation/editor/components/keyboard_exit_actions.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _diagnostic = AppDiagnostic(
  code: 'variableNotDeclared',
  message: 'La variable x no está declarada',
  severity: AppSeverity.error,
  primaryRange: SourceRange(
    startOffset: 10,
    endOffset: 15,
    startLine: 2,
    startColumn: 3,
    endLine: 2,
    endColumn: 8,
  ),
);

Widget _strip({
  required bool offersExitActions,
  List<AppDiagnostic> diagnostics = const [],
  bool canRun = true,
  VoidCallback? onRun,
  VoidCallback? onHideKeyboard,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: DesignCanvas(
        child: EditorDiagnosticsStrip(
          diagnostics: diagnostics,
          onDiagnosticTap: (_) {},
          offersExitActions: offersExitActions,
          canRun: canRun,
          onRun: onRun ?? () {},
          onHideKeyboard: onHideKeyboard ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  group('EditorDiagnosticsStrip', () {
    testWidgets('keeps counting diagnostics while it hosts the exit actions', (tester) async {
      await tester.pumpWidget(_strip(
        offersExitActions: true,
        diagnostics: const [_diagnostic],
      ));
      await tester.pumpAndSettle();

      expect(find.text('1 problema'), findsOneWidget);
      expect(find.byType(KeyboardExitActions), findsOneWidget);
    });

    testWidgets('without exit actions it neither runs nor swallows the tap', (tester) async {
      var hides = 0;

      await tester.pumpWidget(_strip(
        offersExitActions: false,
        onHideKeyboard: () => hides++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sin problemas'));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardExitActions), findsNothing);
      expect(hides, 0);
    });

    testWidgets('a tap on its empty room asks to hide the keyboard', (tester) async {
      var hides = 0;

      await tester.pumpWidget(_strip(
        offersExitActions: true,
        onHideKeyboard: () => hides++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sin problemas'));
      await tester.pumpAndSettle();

      expect(hides, 1);
    });

    testWidgets('a tap on the run action runs instead of hiding', (tester) async {
      var runs = 0;
      var hides = 0;

      await tester.pumpWidget(_strip(
        offersExitActions: true,
        onRun: () => runs++,
        onHideKeyboard: () => hides++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ejecutar'));
      await tester.pumpAndSettle();

      expect(runs, 1);
      expect(hides, 0);
    });
  });
}
