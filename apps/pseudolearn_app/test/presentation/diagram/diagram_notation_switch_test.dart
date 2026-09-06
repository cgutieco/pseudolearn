import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/presentation/diagram/diagram_notation_switch.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/component_metrics.dart';

Future<void> _pumpSwitch(
  WidgetTester tester, {
  DiagramNotation notation = DiagramNotation.flowchart,
  required double availableWidth,
  Size windowSize = const Size(1440, 900),
  ValueChanged<DiagramNotation>? onSelected,
}) async {
  tester.view.physicalSize = windowSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
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
          child: Align(
            alignment: Alignment.topLeft,
            child: DiagramNotationSwitch(
              notation: notation,
              availableWidth: availableWidth,
              onSelected: onSelected,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DiagramNotationSwitch', () {
    testWidgets('renders as a dropdown button when the canvas is narrower than the segmented bar', (tester) async {
      DiagramNotation? selected;
      await _pumpSwitch(
        tester,
        notation: DiagramNotation.flowchart,
        availableWidth: ComponentMetricsTokens.diagramNotationSegmentedMinWidth - 1,
        onSelected: (n) => selected = n,
      );

      expect(find.byType(DropdownButton<DiagramNotation>), findsOneWidget);
      expect(find.text('Ordinograma'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<DiagramNotation>));
      await tester.pumpAndSettle();

      expect(find.text('Estructograma').last, findsOneWidget);
      expect(find.text('Diagrama de clases').last, findsOneWidget);

      await tester.tap(find.text('Estructograma').last);
      await tester.pumpAndSettle();

      expect(selected, DiagramNotation.structogram);
    });

    testWidgets('renders as a segmented bar when the canvas is at least as wide as the token', (tester) async {
      DiagramNotation? selected;
      await _pumpSwitch(
        tester,
        notation: DiagramNotation.flowchart,
        availableWidth: ComponentMetricsTokens.diagramNotationSegmentedMinWidth,
        onSelected: (n) => selected = n,
      );

      expect(find.byType(DropdownButton<DiagramNotation>), findsNothing);
      expect(find.text('Ordinograma'), findsOneWidget);
      expect(find.text('Estructograma'), findsOneWidget);
      expect(find.text('Diagrama de clases'), findsOneWidget);

      await tester.tap(find.text('Diagrama de clases'));
      await tester.pumpAndSettle();

      expect(selected, DiagramNotation.classDiagram);
    });

    testWidgets('a narrow canvas inside a wide window still renders as a dropdown', (tester) async {
      await _pumpSwitch(
        tester,
        availableWidth: 700.0,
        windowSize: const Size(1440, 900),
      );

      expect(find.byType(DropdownButton<DiagramNotation>), findsOneWidget);
    });

    testWidgets('the segmented bar for three notations in Spanish fits under its own token', (tester) async {
      await _pumpSwitch(
        tester,
        availableWidth: ComponentMetricsTokens.diagramNotationSegmentedMinWidth,
      );

      final rect = tester.getRect(find.byType(DiagramNotationSwitch));
      expect(rect.width, lessThanOrEqualTo(ComponentMetricsTokens.diagramNotationSegmentedMinWidth));
    });

    testWidgets('fits comfortably within compact canvas bounds without clipping', (tester) async {
      await _pumpSwitch(
        tester,
        availableWidth: 360.0,
        windowSize: const Size(360, 640),
      );

      final rect = tester.getRect(find.byType(DiagramNotationSwitch));
      expect(rect.width, lessThan(300.0));
      expect(rect.left, greaterThanOrEqualTo(0.0));
      expect(rect.right, lessThanOrEqualTo(360.0));
    });
  });
}
