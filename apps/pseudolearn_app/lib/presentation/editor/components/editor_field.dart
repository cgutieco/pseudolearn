import 'package:flutter/material.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_state.dart';
import '../../../domain/model/editor/editor_key.dart';
import '../code_field.dart';
import '../highlight_controller.dart';
import 'editor_key_shortcuts.dart';

final class EditorField extends StatelessWidget {
  final HighlightController controller;
  final FocusNode focusNode;
  final EditorState editorState;
  final ExecutionState executionState;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<EditorKey> onKeyPressed;

  const EditorField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.editorState,
    required this.executionState,
    required this.onCodeChanged,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return EditorKeyShortcuts(
      onIndent: () => onKeyPressed(const EditorKey.indent()),
      onDedent: () => onKeyPressed(const EditorKey.dedent()),
      onReleaseFocus: focusNode.unfocus,
      child: CodeField(
        controller: controller,
        focusNode: focusNode,
        highlightSpans: editorState.report.highlightSpans,
        focus: executionState.isInFlight
            ? executionState.currentStep.focus
            : null,
        isReadOnly: executionState.isInFlight,
        onChanged: onCodeChanged,
      ),
    );
  }
}
