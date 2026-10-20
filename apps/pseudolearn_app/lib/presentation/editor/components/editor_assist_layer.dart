import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../application/editor/editor_state.dart';
import '../../../domain/model/completion/completion_item.dart';
import '../../../domain/model/editor/editor_key.dart';
import 'editor_assist_overlay.dart';
import 'editor_assist_geometry.dart';

final class EditorAssistLayer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final EditorState editorState;
  final bool assistanceEnabled;
  final bool usesSuggestionBar;
  final ValueChanged<EditorKey> onKeyPressed;
  final Widget child;

  const EditorAssistLayer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.editorState,
    required this.assistanceEnabled,
    this.usesSuggestionBar = false,
    required this.onKeyPressed,
    required this.child,
  });

  @override
  State<EditorAssistLayer> createState() => _EditorAssistLayerState();
}

final class _EditorAssistLayerState extends State<EditorAssistLayer> {
  int _selected = 0;
  bool _invoked = false;
  bool _dismissed = false;
  EditorAssistAnchor? _anchor;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    widget.focusNode.addListener(_refresh);
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(EditorAssistLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_refresh);
      widget.focusNode.addListener(_refresh);
    }
    if (oldWidget.editorState.sourceCode != widget.editorState.sourceCode) {
      _selected = 0;
      _dismissed = false;
    }
    if (widget.editorState.contextualCompletions.isEmpty) _invoked = false;
    _scheduleMeasure();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.focusNode.removeListener(_refresh);
    super.dispose();
  }

  bool get _currentOffer {
    final value = widget.controller.value;
    final state = widget.editorState;
    return widget.focusNode.hasFocus &&
        value.text == state.sourceCode &&
        value.selection.isValid &&
        value.selection.isCollapsed &&
        (value.composing.isCollapsed || !value.composing.isValid) &&
        state.hasCurrentCompletionsAt(value.selection.extentOffset);
  }

  String? get _ghost =>
      !widget.usesSuggestionBar &&
          _currentOffer &&
          widget.assistanceEnabled &&
          !_dismissed &&
          !_invoked
      ? widget.editorState.ghostText
      : null;

  List<CompletionItem> get _popup {
    if (widget.usesSuggestionBar || !_currentOffer) return const [];
    final state = widget.editorState;
    final automatic =
        widget.assistanceEnabled &&
        _ghost == null &&
        state.completionPrefixLength >= 2;
    return !_dismissed && (automatic || _invoked)
        ? state.popupCandidates
        : const [];
  }

  void _refresh() {
    if (!mounted) return;
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
      return;
    }
    setState(() {});
    _scheduleMeasure();
  }

  void _scheduleMeasure() {
    if (_ghost == null && _popup.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final editable = widget.focusNode.context
        ?.findAncestorStateOfType<EditableTextState>();
    final box = context.findRenderObject();
    final selection = widget.controller.selection;
    if (!mounted ||
        editable == null ||
        box is! RenderBox ||
        !selection.isValid) {
      return;
    }
    final anchor = measureEditorAssist(
      editable: editable.renderEditable,
      overlay: box,
      position: TextPosition(offset: selection.extentOffset),
      ghost: _ghost,
    );
    if (anchor != _anchor) setState(() => _anchor = anchor);
  }

  void _accept(CompletionItem item) {
    setState(() => _invoked = false);
    widget.onKeyPressed(EditorKey.ofCompletion(item));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (widget.usesSuggestionBar) return _templateKey(key);
    if (key == LogicalKeyboardKey.space &&
        HardwareKeyboard.instance.isControlPressed) {
      setState(() {
        _invoked = true;
        _dismissed = false;
      });
      _scheduleMeasure();
      return KeyEventResult.handled;
    }
    final popup = _popup;
    if (popup.isNotEmpty) return _popupKey(key, popup);
    final ghost = widget.editorState.inlineCandidate;
    if (_ghost != null && ghost != null) return _ghostKey(key, ghost);
    return _templateKey(key);
  }

  KeyEventResult _popupKey(LogicalKeyboardKey key, List<CompletionItem> popup) {
    final last = popup.length - 1;
    final step = switch (key) {
      LogicalKeyboardKey.arrowDown => _selected >= last ? 0 : _selected + 1,
      LogicalKeyboardKey.arrowUp => _selected <= 0 ? last : _selected - 1,
      _ => null,
    };
    if (step != null) {
      setState(() => _selected = step);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.tab) {
      _accept(popup[_selected.clamp(0, last)]);
      return KeyEventResult.handled;
    }
    return _dismissOn(key);
  }

  KeyEventResult _ghostKey(LogicalKeyboardKey key, CompletionItem ghost) {
    if (key != LogicalKeyboardKey.tab) return _dismissOn(key);
    _accept(ghost);
    return KeyEventResult.handled;
  }

  KeyEventResult _dismissOn(LogicalKeyboardKey key) {
    if (key != LogicalKeyboardKey.escape) return KeyEventResult.ignored;
    setState(() => _dismissed = true);
    return KeyEventResult.handled;
  }

  KeyEventResult _templateKey(LogicalKeyboardKey key) {
    if (!widget.editorState.templateActive) return KeyEventResult.ignored;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final kind = switch (key) {
      LogicalKeyboardKey.tab when shift => EditorKeyKind.stopPrevious,
      LogicalKeyboardKey.tab => EditorKeyKind.stopNext,
      LogicalKeyboardKey.escape => EditorKeyKind.stopExit,
      _ => null,
    };
    if (kind == null) return KeyEventResult.ignored;
    widget.onKeyPressed(EditorKey.stop(kind));
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onKeyEvent: _onKey,
              child: widget.child,
            ),
          ),
          EditorAssistOverlay(
            anchor: _anchor,
            ghostText: _ghost,
            candidates: _popup,
            selectedIndex: _selected,
            onSelected: _accept,
          ),
        ],
      ),
    );
  }

  bool _onScroll(ScrollNotification notification) {
    _scheduleMeasure();
    return false;
  }
}
