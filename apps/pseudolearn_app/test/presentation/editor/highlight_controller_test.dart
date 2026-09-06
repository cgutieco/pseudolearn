import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/presentation/editor/highlight_controller.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _text = 'Definir n Como Entero;';

SourceRange _range(int start, int end) => SourceRange(
      startOffset: start,
      endOffset: end,
      startLine: 1,
      startColumn: start + 1,
      endLine: 1,
      endColumn: end + 1,
    );

HighlightController _controllerWith({SourceRange? focus}) {
  final controller = HighlightController(
    text: _text,
    highlightSpans: [
      HighlightSpan(range: _range(0, 7), category: HighlightCategory.keywordStructured),
      HighlightSpan(range: _range(10, 14), category: HighlightCategory.keywordStructured),
    ],
    syntaxColors: const AppThemeExtension.light().syntax,
  );
  controller.focusBackground = const Color(0xFFCCEEEA);
  controller.updateFocus(focus);
  return controller;
}

List<TextSpan> _spansOf(HighlightController controller, WidgetTester tester) {
  final span = controller.buildTextSpan(
    context: tester.element(find.byType(SizedBox)),
    style: const TextStyle(),
    withComposing: false,
  );
  return (span.children ?? const <InlineSpan>[]).cast<TextSpan>();
}

String _rebuiltText(List<TextSpan> spans) => spans.map((span) => span.text ?? '').join();

void main() {
  group('HighlightController', () {
    testWidgets('without a focus no run carries a background', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final spans = _spansOf(_controllerWith(), tester);

      expect(_rebuiltText(spans), _text);
      for (final span in spans) {
        expect(span.style?.backgroundColor, isNull);
      }
    });

    testWidgets('the focused range is the only part with a background', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final spans = _spansOf(_controllerWith(focus: _range(8, 9)), tester);

      expect(_rebuiltText(spans), _text);
      final highlighted = StringBuffer();
      for (final span in spans) {
        if (span.style?.backgroundColor != null) highlighted.write(span.text);
      }
      expect(highlighted.toString(), 'n');
    });

    testWidgets('a focus that covers a coloured token keeps its colour', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final spans = _spansOf(_controllerWith(focus: _range(0, 7)), tester);

      final first = spans.first;
      expect(first.text, 'Definir');
      expect(first.style?.backgroundColor, isNotNull);
      expect(first.style?.color, isNotNull);
    });

    testWidgets('a focus outside the text changes nothing visible', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final spans = _spansOf(_controllerWith(focus: _range(900, 950)), tester);

      expect(_rebuiltText(spans), _text);
      for (final span in spans) {
        expect(span.style?.backgroundColor, isNull);
      }
    });

    testWidgets('an empty document produces a plain span', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final controller = HighlightController(text: '', syntaxColors: const AppThemeExtension.light().syntax);
      final span = controller.buildTextSpan(
        context: tester.element(find.byType(SizedBox)),
        style: const TextStyle(),
        withComposing: false,
      );

      expect(span.text, '');
    });
  });
}
