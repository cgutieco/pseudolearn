import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/document/components/run_outcome.dart';
import 'package:pseudolearn_app/presentation/document/components/run_result_pill.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic_severity.dart';

SeverityItemColors _error(SeverityColors colors) => colors.error;

const RunOutcome _outcome = (
  tone: _error,
  icon: Icons.close_rounded,
  label: 'Error · línea 3',
  note: 'Fallo',
);

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: DesignCanvas(child: child)),
);

void main() {
  group('RunResultPill', () {
    testWidgets('shows its label and icon', (tester) async {
      await tester.pumpWidget(_wrap(const Center(child: RunResultPill(outcome: _outcome))));

      expect(find.text('Error · línea 3'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('Fallo'), findsNothing);
    });

    testWidgets('a tappable pill reports the tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(Center(child: RunResultPill(outcome: _outcome, onTap: () => taps++))),
      );

      await tester.tap(find.byType(RunResultPill));

      expect(taps, 1);
    });

    testWidgets('a pill without action is not announced as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const Center(child: RunResultPill(outcome: _outcome))));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Error · línea 3')),
        matchesSemantics(label: 'Error · línea 3', isButton: false),
      );
      handle.dispose();
    });
  });
}
