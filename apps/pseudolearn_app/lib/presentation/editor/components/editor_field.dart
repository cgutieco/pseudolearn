import 'package:material_ui/material_ui.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_state.dart';
import '../../../domain/model/analysis/source_range.dart';
import '../../../domain/model/editor/editor_key.dart';
import '../code_field.dart';
import '../highlight_controller.dart';
import 'editor_assist_layer.dart';
import 'editor_key_shortcuts.dart';
import 'keyword_help_layer.dart';

final class EditorField extends StatelessWidget {
  final HighlightController controller;
  final FocusNode focusNode;
  final EditorState editorState;
  final ExecutionState executionState;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<EditorKey> onKeyPressed;
  final bool assistanceEnabled;
  final bool usesSuggestionBar;
  final VoidCallback? onHelpRequested;
  final SourceRange? helpKeyword;
  final ValueChanged<SourceRange> onExplainKeyword;

  const EditorField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.editorState,
    required this.executionState,
    required this.onCodeChanged,
    required this.onKeyPressed,
    this.assistanceEnabled = false,
    this.usesSuggestionBar = false,
    this.onHelpRequested,
    this.helpKeyword,
    required this.onExplainKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return EditorKeyShortcuts(
      onIndent: () => onKeyPressed(const EditorKey.indent()),
      onDedent: () => onKeyPressed(const EditorKey.dedent()),
      onReleaseFocus: focusNode.unfocus,
      onHelp: onHelpRequested,
      child: EditorAssistLayer(
        controller: controller,
        focusNode: focusNode,
        editorState: editorState,
        assistanceEnabled: assistanceEnabled,
        usesSuggestionBar: usesSuggestionBar,
        onKeyPressed: onKeyPressed,
        child: KeywordHelpLayer(
          controller: controller,
          focusNode: focusNode,
          sourceCode: editorState.sourceCode,
          keyword: executionState.isInFlight ? null : helpKeyword,
          onExplain: onExplainKeyword,
          child: _FieldCode(field: this),
        ),
      ),
    );
  }
}

final class _FieldCode extends StatelessWidget {
  final EditorField field;

  const _FieldCode({required this.field});

  @override
  Widget build(BuildContext context) {
    final execution = field.executionState;
    return CodeField(
      controller: field.controller,
      focusNode: field.focusNode,
      highlightSpans: field.editorState.report.highlightSpans,
      focus: execution.isInFlight ? execution.currentStep.focus : null,
      isReadOnly: execution.isInFlight,
      onChanged: field.onCodeChanged,
      onExplain: field.onHelpRequested,
    );
  }
}
