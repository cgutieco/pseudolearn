import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/presentation/document/components/output_line_row.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

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
  group('OutputLineRow', () {
    testWidgets('an echo reads as an assignment with its line', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OutputLineRow(
            line: OutputLine(
              text: '5',
              kind: OutputLineKind.userInputEcho,
              target: 'numero',
              sourceLine: 4,
            ),
          ),
        ),
      );
      expect(find.text('numero <- '), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Línea 4'), findsOneWidget);
    });

    testWidgets('a rejected value is struck through and tagged', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const OutputLineRow(
            line: OutputLine(
              text: 'veinte',
              kind: OutputLineKind.rejectedInput,
              target: 'edad',
              sourceLine: 7,
            ),
          ),
        ),
      );
      final value = tester.widget<Text>(find.text('veinte'));
      expect(value.style?.decoration, TextDecoration.lineThrough);
      expect(find.text('rechazado'), findsOneWidget);
    });

    testWidgets('an echo without a variable keeps the arrow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OutputLineRow(
            line: OutputLine(text: '5', kind: OutputLineKind.userInputEcho),
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('program output is plain text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OutputLineRow(
            line: OutputLine(text: 'hola', kind: OutputLineKind.programOutput),
          ),
        ),
      );
      expect(find.text('hola'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });
  });
}
