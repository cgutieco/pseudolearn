import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/editor/highlight_controller.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildCodeField({
  required HighlightController controller,
  ExecutionFocus? focus,
  Set<int> activeLines = const {},
  ValueChanged<String>? onChanged,
  bool isReadOnly = false,
  FocusNode? focusNode,
  double width = 360,
  double height = 400,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: DesignCanvas(
        child: SizedBox(
          width: width,
          height: height,
          child: CodeField(
            controller: controller,
            focus: focus,
            activeLines: activeLines,
            onChanged: onChanged,
            isReadOnly: isReadOnly,
            focusNode: focusNode,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('CodeField', () {
    testWidgets('renders all lines and gutter line numbers', (tester) async {
      const code = 'algoritmo Uno\n  escribir "Hola"\nfin';

      await tester.pumpWidget(
          _buildCodeField(controller: HighlightController(text: code)));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text(code), findsOneWidget);
    });

    testWidgets('allows horizontal scrolling without soft-wrapping long lines',
        (tester) async {
      const longLine =
          '    Escribir "Mensaje sumamente largo que sobrepasa el ancho disponible en pantalla para validar scroll";';
      const code = 'Proceso Largo\n$longLine\nFinProceso';

      await tester.pumpWidget(_buildCodeField(
          controller: HighlightController(text: code), width: 260));
      await tester.pumpAndSettle();

      final horizontalScroll = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );
      expect(horizontalScroll, findsOneWidget);

      final scrollable = tester.widget<SingleChildScrollView>(horizontalScroll);
      expect(scrollable.scrollDirection, Axis.horizontal);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsNothing);

      await tester.drag(horizontalScroll, const Offset(-120, 0));
      await tester.pumpAndSettle();

      expect(find.text(code), findsOneWidget);
    });

    testWidgets('highlights active lines in gutter', (tester) async {
      const code = 'linea Uno\nlinea Dos\nlinea Tres';

      await tester.pumpWidget(_buildCodeField(
          controller: HighlightController(text: code), activeLines: const {2}));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('highlights focused lines from execution focus',
        (tester) async {
      const code = 'linea Uno\nlinea Dos\nlinea Tres';
      const focus = ExecutionFocus(
        nodeId: ProgramNodeId(1),
        range: SourceRange(
          startOffset: 10,
          endOffset: 19,
          startLine: 2,
          startColumn: 1,
          endLine: 2,
          endColumn: 10,
        ),
        kind: ExecutionFocusKind.statement,
      );

      await tester.pumpWidget(_buildCodeField(
          controller: HighlightController(text: code), focus: focus));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('invokes onChanged and updates line numbers when editing',
        (tester) async {
      var updatedText = '';
      await tester.pumpWidget(_buildCodeField(
        controller: HighlightController(text: 'linea 1'),
        onChanged: (text) => updatedText = text,
      ));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);

      await tester.enterText(find.byType(TextField), 'linea 1\nlinea 2');
      await tester.pumpAndSettle();

      expect(updatedText, 'linea 1\nlinea 2');
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('handles empty text and single line gracefully',
        (tester) async {
      await tester.pumpWidget(
          _buildCodeField(controller: HighlightController(text: '')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1'), findsOneWidget);

      await tester.pumpWidget(_buildCodeField(
          controller: HighlightController(text: 'algoritmo Solo')));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('algoritmo Solo'), findsOneWidget);
    });

    testWidgets('updates vertical reveal position when focus line changes',
        (tester) async {
      final code = List.generate(30, (i) => 'instruccion $i').join('\n');

      await tester.pumpWidget(_buildCodeField(
          controller: HighlightController(text: code), activeLines: const {1}));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_buildCodeField(
          controller: HighlightController(text: code),
          activeLines: const {25}));
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets(
        'editor text field suppresses outline borders and configures caret tokens',
        (tester) async {
      await tester.pumpWidget(
          _buildCodeField(controller: HighlightController(text: 'linea 1')));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.border, InputBorder.none);
      expect(field.decoration?.focusedBorder, InputBorder.none);
      expect(field.decoration?.enabledBorder, InputBorder.none);
      expect(field.cursorWidth, 2.0);
    });

    testWidgets(
        'gutter highlights cursor line when focused and execution focus is null',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final controller = HighlightController(text: 'linea 1\nlinea 2\nlinea 3');
      await tester.pumpWidget(
          _buildCodeField(controller: controller, focusNode: focusNode));
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      controller.selection = const TextSelection.collapsed(offset: 8);
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });
  });
}
