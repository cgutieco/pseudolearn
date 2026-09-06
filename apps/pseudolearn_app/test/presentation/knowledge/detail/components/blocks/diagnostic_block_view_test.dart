import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/presentation/editor/components/severity_chip.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/blocks/diagnostic_block_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, DiagnosticBlock block, {Locale locale = const Locale('es')}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(body: DiagnosticBlockView(block: block)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('DiagnosticBlockView', () {
    testWidgets('Renders error diagnostic card with severity chip, message and code caption', (tester) async {
      const block = DiagnosticBlock(
        code: 'expectedAlgorithmStart',
        message: 'Se esperaba el inicio del algoritmo',
        severity: AppSeverity.error,
      );

      await _pump(tester, block);

      expect(find.byType(SeverityChip), findsOneWidget);
      expect(find.text('ERROR'), findsOneWidget);
      expect(find.text('Se esperaba el inicio del algoritmo'), findsOneWidget);
      expect(find.text('expectedAlgorithmStart'), findsOneWidget);
    });

    testWidgets('Renders warning diagnostic card with warning label in english', (tester) async {
      const block = DiagnosticBlock(
        code: 'variableDeclaredNeverUsed',
        message: 'Variable declared but never used',
        severity: AppSeverity.warning,
      );

      await _pump(tester, block, locale: const Locale('en'));

      expect(find.byType(SeverityChip), findsOneWidget);
      expect(find.text('WARNING'), findsOneWidget);
      expect(find.text('Variable declared but never used'), findsOneWidget);
      expect(find.text('variableDeclaredNeverUsed'), findsOneWidget);
    });
  });
}
