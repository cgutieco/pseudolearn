import 'package:flutter/material.dart';
import '../../application/editor/editor_state.dart';
import '../../application/execution/execution_state.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/editor/editor_key.dart';
import '../shell/design_canvas.dart';
import '../shell/device_class.dart';
import 'components/editor_diagnostics_strip.dart';
import 'components/editor_field.dart';
import 'components/editor_help_action.dart';
import 'editor_key_bar.dart';
import 'highlight_controller.dart';

typedef EditorKeyPressed = void Function(EditorKey key, CaretRange caret);
typedef EditorCodeChanged = void Function(String sourceCode, int cursorUtf16);

final class EditorSurface extends StatefulWidget {
  final EditorState editorState;
  final ExecutionState executionState;
  final EditorCodeChanged onCodeChanged;
  final ValueChanged<int>? onCursorMoved;
  final ValueChanged<AppDiagnostic> onDiagnosticSelected;
  final EditorKeyPressed onKeyPressed;
  final VoidCallback onRun;
  final bool keepsKeyBar;
  final bool assistanceEnabled;
  final ValueChanged<CaretRange>? onHelpRequested;
  final Widget? helpPanel;

  const EditorSurface({
    super.key,
    required this.editorState,
    required this.executionState,
    required this.onCodeChanged,
    this.onCursorMoved,
    required this.onDiagnosticSelected,
    required this.onKeyPressed,
    required this.onRun,
    this.keepsKeyBar = true,
    this.assistanceEnabled = false,
    this.onHelpRequested,
    this.helpPanel,
  });

  @override
  State<EditorSurface> createState() => _EditorSurfaceState();
}

final class _EditorSurfaceState extends State<EditorSurface> {
  late final HighlightController _controller;
  late final FocusNode _focusNode;
  int _appliedRevision = 0;
  int _reportedCursor = -1;

  @override
  void initState() {
    super.initState();
    _controller = HighlightController(text: widget.editorState.sourceCode);
    _focusNode = FocusNode();
    _controller.addListener(_reportCursorChange);

    _appliedRevision = widget.editorState.pendingEdit?.revision ?? 0;
  }

  @override
  void didUpdateWidget(EditorSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(oldWidget.editorState.sourceCode);
    _reportCursorChange();
  }

  @override
  void dispose() {
    _controller.removeListener(_reportCursorChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _reportCursorChange() {
    final selection = _controller.selection;
    if (_controller.text != widget.editorState.sourceCode ||
        !selection.isCollapsed ||
        selection.baseOffset < 0 ||
        selection.baseOffset == _reportedCursor) {
      return;
    }
    _reportedCursor = selection.baseOffset;
    widget.onCursorMoved?.call(_reportedCursor);
  }

  void _onCodeChanged(String sourceCode) {
    final cursor = _controller.selection.baseOffset;
    _reportedCursor = cursor;
    widget.onCodeChanged(sourceCode, cursor);
  }

  void _syncController(String previousSourceCode) {
    final edit = widget.editorState.pendingEdit;
    if (edit != null && edit.revision != _appliedRevision) {
      _appliedRevision = edit.revision;
      _controller.value = TextEditingValue(
        text: edit.sourceCode,
        selection: TextSelection(
          baseOffset: edit.caret.start,
          extentOffset: edit.caret.end,
        ),
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

  void _requestHelp() => widget.onHelpRequested?.call(_caret());

  void _run() {
    _focusNode.unfocus();
    widget.onRun();
  }

  bool get _canRun =>
      widget.editorState.report.isExecutable && widget.executionState.canStart;

  VoidCallback? get _help =>
      widget.onHelpRequested == null ? null : _requestHelp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: EditorField(
            controller: _controller,
            focusNode: _focusNode,
            editorState: widget.editorState,
            executionState: widget.executionState,
            onCodeChanged: _onCodeChanged,
            onKeyPressed: _press,
            assistanceEnabled: widget.assistanceEnabled,
            usesSuggestionBar: _usesSuggestionBar,
            onHelpRequested: _help,
          ),
        ),
        _UnderFieldBars(
          editorState: widget.editorState,
          offersKeyBar: _usesSuggestionBar,
          onDiagnosticTap: widget.onDiagnosticSelected,
          onKeyPressed: _press,
          assistanceEnabled: widget.assistanceEnabled,
          onRun: _canRun ? _run : null,
          onHideKeyboard: _focusNode.unfocus,
          help: EditorHelpDock(onPressed: _help, panel: widget.helpPanel),
        ),
      ],
    );
  }

  bool get _usesSuggestionBar => widget.editorState.usesSuggestionBar(
    keyboardVisible: DesignCanvasScope.of(context).isKeyboardVisible,
    keepsKeyBar: widget.keepsKeyBar,
    isExecuting: widget.executionState.isInFlight,
  );
}

final class _UnderFieldBars extends StatelessWidget {
  final EditorState editorState;
  final bool offersKeyBar;
  final bool assistanceEnabled;
  final ValueChanged<AppDiagnostic> onDiagnosticTap;
  final ValueChanged<EditorKey> onKeyPressed;
  final VoidCallback? onRun;
  final VoidCallback onHideKeyboard;
  final Widget help;

  const _UnderFieldBars({
    required this.editorState,
    required this.offersKeyBar,
    required this.assistanceEnabled,
    required this.onDiagnosticTap,
    required this.onKeyPressed,
    required this.onRun,
    required this.onHideKeyboard,
    required this.help,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        help,
        EditorDiagnosticsStrip(
          diagnostics: editorState.report.diagnostics,
          onDiagnosticTap: onDiagnosticTap,
          offersExitActions:
              canvas.deviceClass == DeviceClass.compact &&
              canvas.isKeyboardVisible,
          canRun: onRun != null,
          onRun: onRun ?? onHideKeyboard,
          onHideKeyboard: onHideKeyboard,
        ),
        if (offersKeyBar)
          EditorKeyBar(
            keys: editorState.keys,
            templates: editorState.contextualCompletions.isNotEmpty
                ? editorState.contextualCompletions
                : editorState.completions,
            onKeyPressed: onKeyPressed,
            alwaysShowsCandidates: assistanceEnabled,
            templateActive: editorState.templateActive,
          ),
      ],
    );
  }
}
