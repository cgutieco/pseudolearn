import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/editor/components/keyboard_exit_actions.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _actions({
  required bool canRun,
  required VoidCallback onRun,
  required VoidCallback onHideKeyboard,
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
    home: DesignCanvas(
      child: Scaffold(
        body: KeyboardExitActions(
          canRun: canRun,
          onRun: onRun,
          onHideKeyboard: onHideKeyboard,
        ),
      ),
    ),
  );
}

void main() {
  group('KeyboardExitActions', () {
    testWidgets('names both ways out of the keyboard', (tester) async {
      await tester.pumpWidget(_actions(canRun: true, onRun: () {}, onHideKeyboard: () {}));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Ejecutar'), findsOneWidget);
      expect(find.byTooltip('Ocultar teclado'), findsOneWidget);
    });

    testWidgets('an executable program reports the run', (tester) async {
      var runs = 0;

      await tester.pumpWidget(
        _actions(canRun: true, onRun: () => runs++, onHideKeyboard: () {}),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ejecutar'));
      await tester.pumpAndSettle();

      expect(runs, 1);
    });

    testWidgets('a program that cannot run reports nothing', (tester) async {
      var runs = 0;

      await tester.pumpWidget(
        _actions(canRun: false, onRun: () => runs++, onHideKeyboard: () {}),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ejecutar'));
      await tester.pumpAndSettle();

      expect(runs, 0);
    });

    testWidgets('hiding stays available even when the program cannot run', (tester) async {
      var hides = 0;

      await tester.pumpWidget(
        _actions(canRun: false, onRun: () {}, onHideKeyboard: () => hides++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ocultar teclado'));
      await tester.pumpAndSettle();

      expect(hides, 1);
    });
  });
}
