import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pseudolearn_app/domain/model/execution/read_request.dart';
import 'package:pseudolearn_app/domain/model/execution/read_value_type.dart';
import 'package:pseudolearn_app/presentation/document/read_line/read_line.dart';
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

ReadRequest _request({
  ReadValueType? type = ReadValueType.integer,
  ReadRejection? rejection,
  String designator = 'numero',
}) => ReadRequest(
  designator: designator,
  valueType: type,
  line: 4,
  statementText: 'Leer numero;',
  rejection: rejection,
);

TextField _field(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

void main() {
  group('ReadLine', () {
    testWidgets('shows the read as an assignment to its variable', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ReadLine(request: _request(), onSubmit: (_) {})),
      );
      expect(find.text('numero'), findsOneWidget);
      expect(find.text('<-'), findsOneWidget);
      expect(find.text('Línea 4'), findsOneWidget);
      expect(find.text('Leer numero;'), findsOneWidget);
      expect(
        find.text('Entero · lo que escribas se guarda en numero'),
        findsOneWidget,
      );
    });

    testWidgets('assigning sends the text and clears the field', (
      tester,
    ) async {
      final sent = <String>[];
      await tester.pumpWidget(
        _wrap(ReadLine(request: _request(), onSubmit: sent.add)),
      );
      await tester.enterText(find.byType(TextField), '42');
      await tester.tap(find.text('Asignar'));
      await tester.pump();
      expect(sent, ['42']);
      expect(_field(tester).controller?.text, '');
    });

    testWidgets('the keyboard action also assigns, even an empty value', (
      tester,
    ) async {
      final sent = <String>[];
      await tester.pumpWidget(
        _wrap(
          ReadLine(
            request: _request(type: ReadValueType.text),
            onSubmit: sent.add,
          ),
        ),
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(sent, ['']);
    });

    testWidgets('a rejection shows the engine message and keeps the value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ReadLine(
            request: _request(
              rejection: const ReadRejection(
                rejectedText: 'veinte',
                message: 'Se esperaba un valor de tipo Entero',
              ),
            ),
            onSubmit: (_) {},
          ),
        ),
      );
      expect(find.text('Se esperaba un valor de tipo Entero'), findsOneWidget);
      expect(_field(tester).controller?.text, 'veinte');
    });

    testWidgets('a rejection without a message explains the type', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ReadLine(
            request: _request(rejection: const ReadRejection()),
            onSubmit: (_) {},
          ),
        ),
      );
      expect(
        find.text('numero espera un valor de tipo Entero. Escribe otro.'),
        findsOneWidget,
      );
      expect(_field(tester).controller?.text, '');
    });

    testWidgets('numbers open a numeric keyboard', (tester) async {
      await tester.pumpWidget(
        _wrap(ReadLine(request: _request(), onSubmit: (_) {})),
      );
      expect(
        _field(tester).keyboardType,
        const TextInputType.numberWithOptions(signed: true),
      );
    });

    testWidgets('a boolean offers both values as shortcuts', (tester) async {
      final sent = <String>[];
      await tester.pumpWidget(
        _wrap(
          ReadLine(
            request: _request(type: ReadValueType.boolean),
            onSubmit: sent.add,
          ),
        ),
      );
      await tester.tap(find.text('Falso'));
      expect(sent, ['Falso']);
    });

    testWidgets('without a request it still accepts a value', (tester) async {
      final sent = <String>[];
      await tester.pumpWidget(
        _wrap(ReadLine(request: null, onSubmit: sent.add)),
      );
      expect(find.text('<-'), findsNothing);
      await tester.enterText(find.byType(TextField), 'x');
      await tester.tap(find.text('Asignar'));
      expect(sent, ['x']);
    });

    testWidgets('an untyped request explains where the value goes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ReadLine(
            request: _request(type: null, designator: 'v[1]'),
            onSubmit: (_) {},
          ),
        ),
      );
      expect(find.text('Lo que escribas se guarda en v[1]'), findsOneWidget);
      expect(_field(tester).keyboardType, TextInputType.text);
    });

    testWidgets('a new request replaces the typed text', (tester) async {
      final first = _request();
      await tester.pumpWidget(
        _wrap(ReadLine(request: first, onSubmit: (_) {})),
      );
      await tester.enterText(find.byType(TextField), '7');
      await tester.pumpWidget(
        _wrap(
          ReadLine(
            request: _request(
              designator: 'b',
              rejection: const ReadRejection(rejectedText: 'x'),
            ),
            onSubmit: (_) {},
          ),
        ),
      );
      expect(_field(tester).controller?.text, 'x');
    });
  });
}
