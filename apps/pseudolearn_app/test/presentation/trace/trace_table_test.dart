import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/trace/trace_state.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/trace/trace_table.dart';

void main() {
  testWidgets('TraceTable renders headers, variable values and aliasing badges', (tester) async {
    const row1 = TraceTableRow(
      stepNumber: 1,
      lineNumber: 4,
      scopeName: 'Principal',
      cells: {
        'a': TraceTableCell(formattedValue: '42'),
        'obj': TraceTableCell(formattedValue: 'Punto#1', identityBadge: 1),
      },
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
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
          child: TraceTable(
            rows: [row1],
            variableNames: ['a', 'obj'],
            activeRowIndex: 0,
          ),
        ),
      ),
    ));

    expect(find.text('Paso'), findsOneWidget);
    expect(find.text('Línea'), findsOneWidget);
    expect(find.text('Ámbito'), findsOneWidget);
    expect(find.text('a'), findsOneWidget);
    expect(find.text('obj'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
  });
}
