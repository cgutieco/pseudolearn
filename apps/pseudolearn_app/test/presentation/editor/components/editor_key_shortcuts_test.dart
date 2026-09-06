import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_key_shortcuts.dart';

final class _Recorder {
  int indents = 0;
  int dedents = 0;
}

Widget _shortcuts(_Recorder recorder, FocusNode node) {
  return MaterialApp(
    home: Scaffold(
      body: EditorKeyShortcuts(
        onIndent: () => recorder.indents++,
        onDedent: () => recorder.dedents++,
        onReleaseFocus: node.unfocus,
        child: TextField(focusNode: node, maxLines: null),
      ),
    ),
  );
}

void main() {
  group('EditorKeyShortcuts', () {
    testWidgets('the physical tab indents instead of moving the focus', (tester) async {
      final recorder = _Recorder();
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(_shortcuts(recorder, node));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(recorder.indents, 1);
      expect(recorder.dedents, 0);
      expect(node.hasFocus, isTrue);
    });

    testWidgets('shift and tab removes one level', (tester) async {
      final recorder = _Recorder();
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(_shortcuts(recorder, node));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(recorder.dedents, 1);
      expect(recorder.indents, 0);
    });

    testWidgets('escape gives the tab back to the focus traversal', (tester) async {
      final recorder = _Recorder();
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(_shortcuts(recorder, node));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(node.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(recorder.indents, 0);
    });
  });
}
