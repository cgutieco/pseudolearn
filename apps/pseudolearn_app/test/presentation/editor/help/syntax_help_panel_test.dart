import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/help/syntax_help.dart';
import 'package:pseudolearn_app/presentation/editor/help/syntax_help_panel.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _range = CaretRange(start: 0, end: 1);

const _card = HelpCardSections(
  id: 'help.while',
  title: 'Bucle Mientras',
  summary: 'Repite el cuerpo.',
  purpose: 'La condición se comprueba antes.',
  parts: [HelpPart(identity: 'whileKeyword', text: 'Inicia el bucle.')],
  constraints: ['Condición lógica.'],
  commonErrors: ['Olvidar el cierre.'],
  examples: [
    HelpExampleLink(
      specification: 'LANG.CONTROL.WHILE',
      version: '1.0.0',
      caseId: 'C1',
      profile: 'es',
      strictness: 'estricto',
      kind: 'executable',
      label: 'Programa mínimo',
    ),
  ],
);

Widget _host(HelpQueryResult result, {VoidCallback? onClose, double scale = 1}) {
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
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        textScaler: TextScaler.linear(scale),
      ),
      child: DesignCanvas(
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SyntaxHelpPanel(result: result, onClose: onClose ?? () {}),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the card sections with headings for assistive tech', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const HelpQueryResult.help(
          SyntaxHelp(headline: 'Mientras', range: _range, card: _card),
          revision: 1,
        ),
      ),
    );
    expect(find.text('Bucle Mientras'), findsOneWidget);
    expect(find.text('Repite el cuerpo.'), findsOneWidget);
    expect(find.text('Propósito'), findsOneWidget);
    expect(find.text('Inicia el bucle.'), findsOneWidget);
    expect(find.text('Se ejecuta: Programa mínimo'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Ayuda del lenguaje')), findsWidgets);
    handle.dispose();
  });

  testWidgets('a user symbol shows its headline and an honest note', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const HelpQueryResult.symbol(
          SyntaxHelp(headline: 'x: Entero', range: _range),
          revision: 1,
        ),
      ),
    );
    expect(find.text('x: Entero'), findsOneWidget);
    expect(find.text('Nombre definido en tu programa.'), findsOneWidget);
  });

  testWidgets('partial certainty is disclosed', (tester) async {
    await tester.pumpWidget(
      _host(
        const HelpQueryResult.help(
          SyntaxHelp(
            headline: 'Mientras',
            range: _range,
            card: _card,
            isPartial: true,
          ),
          revision: 1,
        ),
      ),
    );
    expect(find.textContaining('tiene errores'), findsOneWidget);
  });

  testWidgets('each non-help outcome has its own message', (tester) async {
    final messages = {
      const HelpQueryResult.noHelp(revision: 1):
          'No hay ayuda para esta posición.',
      const HelpQueryResult.invalidPosition(revision: 1):
          'La posición del cursor no es válida.',
      const HelpQueryResult.failure(revision: 1):
          'No se pudo consultar la ayuda.',
    };
    for (final entry in messages.entries) {
      await tester.pumpWidget(_host(entry.key));
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('the close button is labelled and reports the tap', (
    tester,
  ) async {
    var closed = 0;
    await tester.pumpWidget(
      _host(const HelpQueryResult.noHelp(revision: 1), onClose: () => closed++),
    );
    await tester.tap(find.byTooltip('Cerrar ayuda'));
    expect(closed, 1);
  });

  testWidgets('large text scales scroll instead of overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const HelpQueryResult.help(
          SyntaxHelp(headline: 'Mientras', range: _range, card: _card),
          revision: 1,
        ),
        scale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
