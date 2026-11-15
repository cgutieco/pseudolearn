import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/help/help_form.dart';
import 'package:pseudolearn_app/domain/model/help/help_part.dart';
import 'package:pseudolearn_app/domain/model/help/help_program.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/help/syntax_help.dart';
import 'package:pseudolearn_app/presentation/editor/help/help_code_views.dart';
import 'package:pseudolearn_app/presentation/editor/help/syntax_help_body.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _hostile = '<script>alert(1)</script> [abrir](javascript:alert(1))';

const _form = [
  HelpFormLine(
    indent: 0,
    segments: [
      HelpFormSegment(kind: HelpFormSegmentKind.word, text: 'Algoritmo'),
      HelpFormSegment(kind: HelpFormSegmentKind.slot, text: 'nombre del programa'),
    ],
  ),
  HelpFormLine(
    indent: 1,
    segments: [HelpFormSegment(kind: HelpFormSegmentKind.ellipsis, text: '...')],
  ),
  HelpFormLine(
    indent: 0,
    segments: [HelpFormSegment(kind: HelpFormSegmentKind.word, text: 'FinAlgoritmo')],
  ),
];

HelpCardSections _card({
  String? result,
  List<String> rules = const [],
  List<HelpCommonError> errors = const [],
  List<HelpExample> examples = const [
    HelpExample(
      kind: HelpExampleKind.executable,
      note: 'Muestra Hola.',
      program: HelpProgram(
        source: 'Algoritmo Saludo\n  Escribir "Hola";\nFinAlgoritmo\n',
        output: 'Hola\n',
      ),
    ),
  ],
}) => HelpCardSections(
  id: 'construction.algorithm.entry',
  title: 'Bloque Algoritmo',
  summary: _hostile,
  category: HelpCategory.block,
  form: _form,
  parts: const [
    HelpPart(kind: HelpPartKind.word, name: 'Algoritmo', text: 'Marca el inicio.'),
    HelpPart(kind: HelpPartKind.slot, name: 'nombre del programa', text: 'Un nombre.'),
  ],
  result: result,
  rules: rules,
  commonErrors: errors,
  examples: examples,
);

Widget _host(HelpCardSections card, {String? description}) => MaterialApp(
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
      body: SingleChildScrollView(
        child: SyntaxHelpBody(
          result: HelpQueryResult.help(
            SyntaxHelp(
              headline: 'Algoritmo',
              description: description,
              card: card,
              range: const CaretRange(start: 0, end: 9),
            ),
            revision: 1,
          ),
        ),
      ),
    ),
  ),
);

String _allText(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((widget) => widget.text.toPlainText())
    .join('\n');

void main() {
  testWidgets('shows the beginner sections in order with the template and example', (tester) async {
    await tester.pumpWidget(_host(_card(result: 'Nada.', rules: ['Ciérralo.'])));
    final text = _allText(tester);
    final order = [
      'Bloque',
      'Bloque Algoritmo',
      'Cómo se escribe',
      'Cada parte',
      'Devuelve',
      'Reglas',
      'Ejemplo',
      'Resultado',
      'Muestra Hola.',
    ].map(text.indexOf).toList();
    expect(order, everyElement(greaterThanOrEqualTo(0)));
    expect(order, orderedEquals([...order]..sort()));
    expect(find.byType(HelpFormView), findsOneWidget);
    expect(find.byType(HelpSlotChip), findsNWidgets(2));
    expect(text, contains('Algoritmo Saludo\n  Escribir "Hola";\nFinAlgoritmo'));
    expect(text, contains('  ...'));
  });

  testWidgets('hostile text is shown literally and nothing but text is tappable', (tester) async {
    await tester.pumpWidget(_host(_card()));
    expect(_allText(tester), contains(_hostile));
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      rich.text.visitChildren((span) {
        expect(span is TextSpan ? span.recognizer : null, isNull);
        return true;
      });
    }
    expect(tester.widgetList(find.byType(TextField)), isEmpty);
    expect(find.byWidgetPredicate((widget) => widget is RawGestureDetector && widget.gestures.containsKey(TapGestureRecognizer)), findsNothing);
  });

  testWidgets('empty sections are hidden and a diagnostic example is announced', (tester) async {
    await tester.pumpWidget(
      _host(
        _card(
          examples: const [
            HelpExample(
              kind: HelpExampleKind.diagnostic,
              note: 'Falta el cierre.',
              program: HelpProgram(source: 'Algoritmo P\n'),
            ),
          ],
        ),
      ),
    );
    final text = _allText(tester);
    for (final hidden in ['Devuelve', 'Reglas', 'Errores comunes', 'Resultado']) {
      expect(text, isNot(contains(hidden)));
    }
    expect(text, contains('Este programa muestra un error'));
  });

  testWidgets('mistakes show their program and several examples use the plural heading', (tester) async {
    const example = HelpExample(
      kind: HelpExampleKind.executable,
      note: 'Uno.',
      program: HelpProgram(source: 'Escribir 1;'),
    );
    await tester.pumpWidget(
      _host(
        _card(
          errors: const [
            HelpCommonError(text: 'Olvidar el cierre.', program: HelpProgram(source: 'Algoritmo P\n')),
            HelpCommonError(text: 'Sin código.'),
          ],
          examples: const [example, example],
        ),
      ),
    );
    final text = _allText(tester);
    expect(text, contains('Errores comunes'));
    expect(text, contains('Ejemplos'));
    expect(find.byType(HelpCodeView), findsNWidgets(3));
  });

  testWidgets('the token description is shown only when there is no card', (tester) async {
    await tester.pumpWidget(_host(_card(), description: 'Descripción del token.'));
    expect(_allText(tester), isNot(contains('Descripción del token.')));
  });
}
