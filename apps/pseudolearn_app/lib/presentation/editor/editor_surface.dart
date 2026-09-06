import 'package:flutter/material.dart';
import '../../application/editor/editor_state.dart';
import '../../application/execution/execution_state.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/editor/editor_key.dart';
import '../shell/design_canvas.dart';
import '../shell/device_class.dart';
import 'code_field.dart';
import 'components/editor_diagnostics_strip.dart';
import 'components/editor_key_shortcuts.dart';
import 'editor_key_bar.dart';
import 'highlight_controller.dart';

typedef EditorKeyPressed = void Function(EditorKey key, CaretRange caret);

final class EditorSurface extends StatefulWidget {
  final EditorState editorState;
  final ExecutionState executionState;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<AppDiagnostic> onDiagnosticSelected;
  final EditorKeyPressed onKeyPressed;
  final VoidCallback onRun;
  final bool keepsKeyBar;

  const EditorSurface({
    super.key,
    required this.editorState,
    required this.executionState,
    required this.onCodeChanged,
    required this.onDiagnosticSelected,
    required this.onKeyPressed,
    required this.onRun,
    this.keepsKeyBar = true,
  });

  @override
  State<EditorSurface> createState() => _EditorSurfaceState();
}

final class _EditorSurfaceState extends State<EditorSurface> {
  late final HighlightController _controller;
  late final FocusNode _focusNode;
  int _appliedRevision = 0;

  @override
  void initState() {
    super.initState();
    _controller = HighlightController(text: widget.editorState.sourceCode);
    _focusNode = FocusNode();

    _appliedRevision = widget.editorState.pendingEdit?.revision ?? 0;
  }

  @override
  void didUpdateWidget(EditorSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(oldWidget.editorState.sourceCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncController(String previousSourceCode) {
    final edit = widget.editorState.pendingEdit;
    if (edit != null && edit.revision != _appliedRevision) {
      _appliedRevision = edit.revision;
      _controller.value = TextEditingValue(
        text: edit.sourceCode,
        selection: TextSelection.collapsed(offset: edit.caret.start),
      );
      _focusNode.requestFocus();
      return;
    }
    final text = widget.editorState.sourceCode;
    if (text != _controller.text && previousSourceCode != text) {
      _controller.text = text;
    }
  }

  CaretRange _caret() {
    final selection = _controller.selection;
    if (selection.start < 0) {
      return CaretRange.collapsed(_controller.text.length);
    }
    return CaretRange(start: selection.start, end: selection.end);
  }

  void _press(EditorKey key) => widget.onKeyPressed(key, _caret());

  void _run() {
    _focusNode.unfocus();
    widget.onRun();
  }

  bool get _canRun =>
      widget.editorState.report.isExecutable && widget.executionState.canStart;

  bool _hidesFooter(DesignCanvasData canvas) =>
      canvas.deviceClass == DeviceClass.compact && canvas.isKeyboardVisible;

  bool _offersKeyBar(DesignCanvasData canvas) =>
      widget.keepsKeyBar &&
      widget.editorState.showsKeyBar &&
      canvas.isKeyboardVisible &&
      widget.editorState.keys.isNotEmpty &&
      !widget.executionState.isInFlight;

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Column(
      children: [
        Expanded(
          child: _EditorField(
            controller: _controller,
            focusNode: _focusNode,
            editorState: widget.editorState,
            executionState: widget.executionState,
            onCodeChanged: widget.onCodeChanged,
            onKeyPressed: _press,
          ),
        ),
        _UnderFieldBars(
          editorState: widget.editorState,
          offersKeyBar: _offersKeyBar(canvas),
          offersExitActions: _hidesFooter(canvas),
          canRun: _canRun,
          onDiagnosticTap: widget.onDiagnosticSelected,
          onKeyPressed: _press,
          onRun: _run,
          onHideKeyboard: _focusNode.unfocus,
        ),
      ],
    );
  }
}

final class _UnderFieldBars extends StatelessWidget {
  final EditorState editorState;
  final bool offersKeyBar;
  final bool offersExitActions;
  final bool canRun;
  final ValueChanged<AppDiagnostic> onDiagnosticTap;
  final ValueChanged<EditorKey> onKeyPressed;
  final VoidCallback onRun;
  final VoidCallback onHideKeyboard;

  const _UnderFieldBars({
    required this.editorState,
    required this.offersKeyBar,
    required this.offersExitActions,
    required this.canRun,
    required this.onDiagnosticTap,
    required this.onKeyPressed,
    required this.onRun,
    required this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditorDiagnosticsStrip(
          diagnostics: editorState.report.diagnostics,
          onDiagnosticTap: onDiagnosticTap,
          offersExitActions: offersExitActions,
          canRun: canRun,
          onRun: onRun,
          onHideKeyboard: onHideKeyboard,
        ),
        if (offersKeyBar)
          EditorKeyBar(
            keys: editorState.keys,
            templates: editorState.completions,
            onKeyPressed: onKeyPressed,
          ),
      ],
    );
  }
}

final class _EditorField extends StatelessWidget {
  final HighlightController controller;
  final FocusNode focusNode;
  final EditorState editorState;
  final ExecutionState executionState;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<EditorKey> onKeyPressed;

  const _EditorField({
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
        focus:
            executionState.isInFlight ? executionState.currentStep.focus : null,
        isReadOnly: executionState.isInFlight,
        onChanged: onCodeChanged,
      ),
    );
  }
}
