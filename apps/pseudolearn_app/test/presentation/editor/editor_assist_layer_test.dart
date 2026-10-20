import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_state.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_assist_layer.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_completion_popup.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_ghost_text.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

CompletionItem _item(String label, {bool inline = false, int revision = 3}) =>
    CompletionItem(
      label: label,
      template: label,
      caretOffset: label.length,
      family: CompletionFamily.structured,
      detailKey: 'structure',
      isInline: inline,
      replacementRange: const CaretRange(start: 0, end: 2),
      revision: revision,
    );

EditorState _state({
  List<CompletionItem> items = const [],
  bool templateActive = false,
  String source = 'Mi',
}) => EditorState.initial().copyWith(
  sourceCode: source,
  contextualCompletions: items,
  completionRevision: 3,
  templateActive: templateActive,
);

Future<List<EditorKey>> _pump(
  WidgetTester tester, {
  required EditorState state,
  required bool enabled,
}) async {
  final pressed = <EditorKey>[];
  final controller = TextEditingController(text: state.sourceCode)
    ..selection = TextSelection.collapsed(offset: state.sourceCode.length);
  final focusNode = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(focusNode.dispose);
  await tester.pumpWidget(
    MaterialApp(
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
          body: EditorAssistLayer(
            controller: controller,
            focusNode: focusNode,
            editorState: state,
            assistanceEnabled: enabled,
            onKeyPressed: pressed.add,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
            ),
          ),
        ),
      ),
    ),
  );
  focusNode.requestFocus();
  await tester.pumpAndSettle();
  return pressed;
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  group('EditorAssistLayer', () {
    testWidgets('shows the popup for two typed characters when enabled', (
      tester,
    ) async {
      await _pump(
        tester,
        state: _state(items: [_item('Mientras'), _item('Mover')]),
        enabled: true,
      );

      expect(find.byType(EditorCompletionPopup), findsOneWidget);
      expect(find.text('Mientras'), findsOneWidget);
    });

    testWidgets('stays silent when the setting is off', (tester) async {
      await _pump(
        tester,
        state: _state(items: [_item('Mientras')]),
        enabled: false,
      );

      expect(find.byType(EditorCompletionPopup), findsNothing);
      expect(find.byType(EditorGhostText), findsNothing);
    });

    testWidgets('Ctrl+Space invokes the popup even when the setting is off', (
      tester,
    ) async {
      await _pump(
        tester,
        state: _state(items: [_item('Mientras')]),
        enabled: false,
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.byType(EditorCompletionPopup), findsOneWidget);
    });

    testWidgets('arrows move the selection and Enter accepts it', (
      tester,
    ) async {
      final pressed = await _pump(
        tester,
        state: _state(items: [_item('Mientras'), _item('Mover')]),
        enabled: true,
      );

      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(pressed.single.label, 'Mover');
      expect(pressed.single.kind, EditorKeyKind.completion);
    });

    testWidgets('Escape hides the popup without accepting', (tester) async {
      final pressed = await _pump(
        tester,
        state: _state(items: [_item('Mientras')]),
        enabled: true,
      );

      await _press(tester, LogicalKeyboardKey.escape);

      expect(find.byType(EditorCompletionPopup), findsNothing);
      expect(pressed, isEmpty);
    });

    testWidgets(
      'shows the ghost text of an inline candidate and Tab accepts it',
      (tester) async {
        final pressed = await _pump(
          tester,
          state: _state(items: [_item('Mientras', inline: true)], source: 'Mi'),
          enabled: true,
        );

        expect(find.byType(EditorGhostText), findsOneWidget);
        expect(find.byType(EditorCompletionPopup), findsNothing);

        await _press(tester, LogicalKeyboardKey.tab);

        expect(pressed.single.label, 'Mientras');
      },
    );

    testWidgets('hides ghost text for stale revisions and a different caret', (
      tester,
    ) async {
      await _pump(
        tester,
        state: _state(items: [_item('Mientras', inline: true, revision: 2)]),
        enabled: true,
      );
      expect(find.byType(EditorGhostText), findsNothing);
      await _pump(
        tester,
        state: _state(items: [_item('Mientras', inline: true)]),
        enabled: true,
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.selection = const TextSelection.collapsed(offset: 1);
      await tester.pumpAndSettle();
      expect(find.byType(EditorGhostText), findsNothing);
    });

    testWidgets(
      'hides ghost text during selection, composition and lost focus',
      (tester) async {
        await _pump(
          tester,
          state: _state(items: [_item('Mientras', inline: true)]),
          enabled: true,
        );
        final field = tester.widget<TextField>(find.byType(TextField));
        final controller = field.controller!;
        controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 2,
        );
        await tester.pumpAndSettle();
        expect(find.byType(EditorGhostText), findsNothing);
        controller.value = controller.value.copyWith(
          selection: const TextSelection.collapsed(offset: 2),
          composing: const TextRange(start: 0, end: 2),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EditorGhostText), findsNothing);
        controller.clearComposing();
        await tester.pumpAndSettle();
        expect(find.byType(EditorGhostText), findsOneWidget);
        field.focusNode!.unfocus();
        await tester.pumpAndSettle();
        expect(find.byType(EditorGhostText), findsNothing);
      },
    );

    testWidgets('Enter preserves a newline and Escape rejects ghost text', (
      tester,
    ) async {
      final pressed = await _pump(
        tester,
        state: _state(items: [_item('Mientras', inline: true)]),
        enabled: true,
      );
      await _press(tester, LogicalKeyboardKey.enter);
      expect(pressed, isEmpty);
      await tester.enterText(find.byType(TextField), 'Mi\n');
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Mi\n');
      await _pump(
        tester,
        state: _state(items: [_item('Mientras', inline: true)]),
        enabled: true,
      );
      await _press(tester, LogicalKeyboardKey.escape);
      expect(find.byType(EditorGhostText), findsNothing);
    });

    testWidgets('Tab, Shift+Tab and Escape walk an active template', (
      tester,
    ) async {
      final pressed = await _pump(
        tester,
        state: _state(templateActive: true),
        enabled: false,
      );

      await _press(tester, LogicalKeyboardKey.tab);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await _press(tester, LogicalKeyboardKey.escape);

      expect(pressed.map((key) => key.kind), [
        EditorKeyKind.stopNext,
        EditorKeyKind.stopPrevious,
        EditorKeyKind.stopExit,
      ]);
    });

    testWidgets('ignores keys when nothing is offered', (tester) async {
      final pressed = await _pump(tester, state: _state(), enabled: true);

      await _press(tester, LogicalKeyboardKey.tab);
      await _press(tester, LogicalKeyboardKey.arrowDown);

      expect(pressed, isEmpty);
    });
  });
}
