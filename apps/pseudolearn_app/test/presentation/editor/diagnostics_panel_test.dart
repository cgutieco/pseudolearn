import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/presentation/editor/diagnostics_panel.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  testWidgets('DiagnosticsPanel expands and displays diagnostic details',
      (tester) async {
    const diagnostic = AppDiagnostic(
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
          child: DiagnosticsPanel(
            diagnostics: [diagnostic],
          ),
        ),
      ),
    ));

    expect(find.text('1 problema'), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('ERROR'), findsOneWidget);
    expect(find.text('L:2 C:3'), findsOneWidget);
    expect(find.text('La variable x no está declarada'), findsOneWidget);
  });

  testWidgets('a collapsed panel swaps its toggle for the trailing actions',
      (tester) async {
    await tester.pumpWidget(_panel(
      isCollapsed: true,
      trailing: const Icon(Icons.play_arrow),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sin problemas'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('an expandable panel with no trailing keeps only its toggle',
      (tester) async {
    await tester.pumpWidget(_panel());
    await tester.pumpAndSettle();

    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });

  testWidgets('a collapsed panel with trailing scales header to key bar height',
      (tester) async {
    await tester.pumpWidget(_panel(
      isCollapsed: true,
      trailing: const SizedBox(height: 32, width: 32),
    ));
    await tester.pumpAndSettle();

    final headerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.constraints?.hasTightHeight == true &&
          widget.constraints?.maxHeight == 40.0,
    );
    expect(headerFinder, findsOneWidget);
  });
}

Widget _panel({bool isCollapsed = false, Widget? trailing}) {
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
        child: DiagnosticsPanel(
          diagnostics: const [],
          isCollapsed: isCollapsed,
          trailing: trailing,
        ),
      ),
    ),
  );
}
