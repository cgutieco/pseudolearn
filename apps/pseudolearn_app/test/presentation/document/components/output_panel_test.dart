import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/presentation/document/components/output_panel.dart';
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
  group('OutputPanel with a pending read', () {
    testWidgets('opens even when collapsed and ends with the read', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          OutputPanel(
            outputLines: const [
              OutputLine(
                text: 'Ingresa un número',
                kind: OutputLineKind.programOutput,
              ),
            ],
            isExpanded: false,
            onToggle: () {},
            pendingRead: const Text('lectura pendiente'),
          ),
        ),
      );
      expect(find.text('Ingresa un número'), findsOneWidget);
      expect(find.text('lectura pendiente'), findsOneWidget);
      final lineTop = tester.getTopLeft(find.text('Ingresa un número')).dy;
      final readTop = tester.getTopLeft(find.text('lectura pendiente')).dy;
      expect(readTop, greaterThan(lineTop));
    });

    testWidgets('a collapsed panel without a read stays closed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          OutputPanel(
            outputLines: const [
              OutputLine(text: 'hola', kind: OutputLineKind.programOutput),
            ],
            isExpanded: false,
            onToggle: () {},
          ),
        ),
      );
      expect(find.text('hola'), findsNothing);
    });
  });
}
