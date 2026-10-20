import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_state.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/presentation/editor/components/code_text_input.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_assist_layer.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_ghost_text.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, String text) async {
  final controller = TextEditingController(text: text)
    ..selection = TextSelection.collapsed(offset: text.length);
  final node = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(node.dispose);
  final state = const EditorState.initial().copyWith(
    sourceCode: text,
    completionRevision: 1,
    contextualCompletions: [
      CompletionItem(
        label: 'baseCalculada',
        template: 'baseCalculada',
        caretOffset: 0,
        family: CompletionFamily.structured,
        isInline: true,
        revision: 1,
        replacementRange: CaretRange(start: text.length - 4, end: text.length),
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: DesignCanvas(
        child: Scaffold(
          body: EditorAssistLayer(
            controller: controller,
            focusNode: node,
            editorState: state,
            assistanceEnabled: true,
            onKeyPressed: (_) {},
            child: SingleChildScrollView(
              child: CodeTextInput(
                controller: controller,
                focusNode: node,
                isReadOnly: false,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  node.requestFocus();
  await tester.pumpAndSettle();
}

double _textTop(RenderEditable editable, int offset) {
  final box = editable
      .getBoxesForSelection(
        TextSelection(baseOffset: offset - 1, extentOffset: offset),
      )
      .last;
  return editable.localToGlobal(Offset(box.left, box.top)).dy;
}

double _ghostTop(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(EditorGhostText),
    matching: find.byType(RichText),
  );
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final box = paragraph
      .getBoxesForSelection(const TextSelection(baseOffset: 0, extentOffset: 1))
      .first;
  return paragraph.localToGlobal(Offset(box.left, box.top)).dy;
}

double _ghostBaseline(WidgetTester tester) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(
      of: find.byType(EditorGhostText),
      matching: find.byType(RichText),
    ),
  );
  final distance = paragraph.computeDistanceToActualBaseline(
    TextBaseline.alphabetic,
  );
  return paragraph.localToGlobal(Offset.zero).dy + distance;
}

double _textBaseline(RenderEditable editable) {
  final distance = editable.computeDistanceToActualBaseline(
    TextBaseline.alphabetic,
  );
  return editable.localToGlobal(Offset.zero).dy + distance;
}

void main() {
  for (final platform in [
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  ]) {
    for (final scale in [1.0, 1.6]) {
      testWidgets('ghost glyph metrics align on $platform at scale $scale', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        const text = 'Leer base';
        await _pump(tester, text);
        final editable = tester
            .state<EditableTextState>(find.byType(EditableText))
            .renderEditable;
        expect(_ghostBaseline(tester), closeTo(_textBaseline(editable), 0.1));
      }, variant: TargetPlatformVariant({platform}));
    }
  }
  testWidgets('the ghost follows the field when its scroll position changes', (
    tester,
  ) async {
    final text = '${List.filled(35, 'Escribir 1;').join('\n')}\n  Leer base';
    await _pump(tester, text);
    final editable = tester
        .state<EditableTextState>(find.byType(EditableText))
        .renderEditable;
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final initial = _ghostTop(tester);
    scrollable.position.jumpTo(0);
    await tester.pumpAndSettle();
    expect(_ghostTop(tester), closeTo(_textTop(editable, text.length), 1.0));
    expect(_ghostTop(tester), isNot(closeTo(initial, 0.1)));
  });
}
