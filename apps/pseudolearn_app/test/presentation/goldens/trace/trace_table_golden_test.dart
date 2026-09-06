import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/trace/trace_state.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/trace/trace_table.dart';

const _rows = <TraceTableRow>[
  TraceTableRow(
    stepNumber: 1,
    lineNumber: 2,
    scopeName: 'Factorial',
    cells: {
      'n': TraceTableCell(formattedValue: '-', hasJustChanged: true),
      'f': TraceTableCell.outOfScope(),
      'i': TraceTableCell.outOfScope(),
    },
  ),
  TraceTableRow(
    stepNumber: 2,
    lineNumber: 5,
    scopeName: 'Factorial',
    cells: {
      'n': TraceTableCell(formattedValue: '5', hasJustChanged: true),
      'f': TraceTableCell(formattedValue: '-'),
      'i': TraceTableCell(formattedValue: '-'),
    },
  ),
  TraceTableRow(
    stepNumber: 3,
    lineNumber: 8,
    scopeName: 'Factorial',
    cells: {
      'n': TraceTableCell(formattedValue: '5'),
      'f': TraceTableCell(formattedValue: '120', hasJustChanged: true),
      'i': TraceTableCell(formattedValue: '5'),
    },
  ),
];

Future<void> _pump(WidgetTester tester, {required Size size, required ThemeData theme}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      body: DesignCanvas(
        child: TraceTable(rows: _rows, variableNames: ['n', 'f', 'i'], activeRowIndex: 2),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('TraceTable goldens', () {
    testWidgets('medium · light', (tester) async {
      await _pump(tester, size: const Size(800, 400), theme: AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('trace_table_medium_light.png'));
    });

    testWidgets('medium · dark', (tester) async {
      await _pump(tester, size: const Size(800, 400), theme: AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('trace_table_medium_dark.png'));
    });

    testWidgets('compact · light', (tester) async {
      await _pump(tester, size: const Size(390, 500), theme: AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('trace_table_compact_light.png'));
    });
  });
}
