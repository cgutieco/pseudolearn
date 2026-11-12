import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_anatomy.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_run.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_token.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/reference/blocks/reference_anatomy_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _app(Widget child, {required bool dark}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, c) => DesignCanvas(child: c ?? const SizedBox.shrink()),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

ReferenceAnatomyPart _part(List<ReferenceToken> tokens, String label) =>
    ReferenceAnatomyPart(tokens: tokens, label: [ReferenceTextRun(label)]);

final _dimension = [
  _part(const [ReferenceToken(text: 'Dimension', category: HighlightCategory.keywordStructured)], 'palabra que crea los arreglos'),
  _part(const [ReferenceToken(text: 'notas'), ReferenceToken(text: '[4]')], 'nombre y tamaño entre corchetes'),
  _part(const [ReferenceToken(text: ',')], 'separa otro arreglo de la misma línea'),
  _part(const [ReferenceToken(text: 'tabla[2, 3]')], 'dos tamaños: filas y columnas'),
  _part(const [ReferenceToken(text: 'Como Entero')], 'tipo de las casillas, para todos los arreglos de la línea'),
];

void _usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('lays every part out on a phone without overflow (dark: $dark)', (tester) async {
      _usePhone(tester);
      await tester.pumpWidget(_app(ReferenceAnatomyView(parts: _dimension, onOpenSection: (_) {}), dark: dark));
      await tester.pumpAndSettle();
      expect(find.text('Pieza por pieza'), findsOneWidget);
      expect(find.textContaining('Dimension', findRichText: true), findsOneWidget);
      expect(find.textContaining('para todos los arreglos', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('places each label under its own code', (tester) async {
    _usePhone(tester);
    await tester.pumpWidget(_app(ReferenceAnatomyView(parts: _dimension, onOpenSection: (_) {}), dark: false));
    await tester.pumpAndSettle();
    final code = tester.getRect(find.textContaining('Dimension', findRichText: true));
    final label = tester.getRect(find.textContaining('palabra que crea', findRichText: true));
    expect(label.top, greaterThan(code.bottom));
    expect(label.left, code.left);
  });

  testWidgets('a part longer than the label width keeps its code on one line', (tester) async {
    _usePhone(tester);
    final long = [
      _part(const [ReferenceToken(text: 'Definir operacion Como')], 'una variable'),
      _part(const [ReferenceToken(text: 'x')], 'una etiqueta que ocupa varias líneas porque es larga a propósito'),
    ];
    await tester.pumpWidget(_app(ReferenceAnatomyView(parts: long, onOpenSection: (_) {}), dark: false));
    await tester.pumpAndSettle();
    final code = tester.getRect(find.textContaining('Definir operacion Como', findRichText: true));
    final wrapped = tester.getRect(find.textContaining('varias líneas', findRichText: true));
    expect(code.height, lessThan(wrapped.height));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an anatomy without parts draws only its frame', (tester) async {
    await tester.pumpWidget(_app(ReferenceAnatomyView(parts: const [], onOpenSection: (_) {}), dark: false));
    await tester.pumpAndSettle();
    expect(find.text('Pieza por pieza'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
