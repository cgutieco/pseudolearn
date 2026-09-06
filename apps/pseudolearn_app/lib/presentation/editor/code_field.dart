import 'package:flutter/material.dart';
import '../../domain/model/analysis/highlight_span.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../components/typography/app_text.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/editor_metrics.dart';
import 'components/line_numbers_gutter.dart';
import 'highlight_controller.dart';

final class CodeField extends StatefulWidget {
  final HighlightController controller;
  final List<HighlightSpan> highlightSpans;
  final ExecutionFocus? focus;
  final Set<int> activeLines;
  final ValueChanged<String>? onChanged;
  final bool isReadOnly;
  final FocusNode? focusNode;

  const CodeField({
    super.key,
    required this.controller,
    this.highlightSpans = const [],
    this.focus,
    this.activeLines = const {},
    this.onChanged,
    this.isReadOnly = false,
    this.focusNode,
  });

  Set<int> get focusedLines => focus == null
      ? activeLines
      : {for (var line = focus!.startLine; line <= focus!.endLine; line++) line};

  @override
  State<CodeField> createState() => _CodeFieldState();
}

final class _CodeFieldState extends State<CodeField> {
  late final ScrollController _scrollController;
  int _lineCount = 1;
  int _cursorLine = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.controller.addListener(_syncController);
    widget.focusNode?.addListener(_onFocusChanged);
    _syncController();
  }

  @override
  void didUpdateWidget(CodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncController);
      widget.controller.addListener(_syncController);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      widget.focusNode?.addListener(_onFocusChanged);
    }
    _syncController();
    widget.controller.updateSpans(widget.highlightSpans);
    widget.controller.updateFocus(widget.focus?.range);
    if (widget.focus != null && oldWidget.focus != widget.focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealFocusedLine());
    }
  }

  void _onFocusChanged() => setState(() {});

  void _syncController() {
    final text = widget.controller.text;
    final count = _lineCountOf(text);
    final cursor = _cursorLineOf(text, widget.controller.selection.baseOffset);
    if (count != _lineCount || cursor != _cursorLine) {
      setState(() {
        _lineCount = count;
        _cursorLine = cursor;
      });
    }
  }

  static int _cursorLineOf(String text, int offset) {
    if (text.isEmpty || offset <= 0) return 1;
    return '\n'.allMatches(text.substring(0, offset.clamp(0, text.length))).length + 1;
  }

  void _revealFocusedLine() {
    final lines = widget.focusedLines;
    if (lines.isEmpty || !_scrollController.hasClients) return;
    var line = lines.first;
    for (final candidate in lines) {
      if (candidate < line) line = candidate;
    }
    final style = resolveAppTextStyle(context, AppTextVariant.codeEditor);
    final lineHeight = style.fontSize! * (style.height ?? 1.0);
    final target = (line - 1) * lineHeight;
    _scrollController.jumpTo(target.clamp(0.0, _scrollController.position.maxScrollExtent));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncController);
    widget.focusNode?.removeListener(_onFocusChanged);
    _scrollController.dispose();
    super.dispose();
  }

  int _lineCountOf(String text) => '\n'.allMatches(text).length + 1;

  void _onTextChanged(String text) {
    _syncController();
    if (widget.onChanged != null) widget.onChanged!(text);
  }

  Set<int> get _activeLines {
    if (widget.focus != null) return widget.focusedLines;
    if (widget.activeLines.isNotEmpty) return widget.activeLines;
    if (widget.focusNode?.hasFocus == true && !widget.isReadOnly) {
      return {_cursorLine};
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    widget.controller.syntaxColors = theme.syntax;
    widget.controller.focusBackground = theme.colors.surfaces.brandSubtle;
    final editorBg = widget.isReadOnly ? theme.colors.surfaces.subtle : theme.colors.surfaces.defaultSurface;

    return Container(
      color: editorBg,
      child: _CodeFieldBody(
        scrollController: _scrollController,
        lineCount: _lineCount,
        activeLines: _activeLines,
        controller: widget.controller,
        isReadOnly: widget.isReadOnly,
        focusNode: widget.focusNode,
        onChanged: _onTextChanged,
      ),
    );
  }
}

final class _CodeFieldBody extends StatelessWidget {
  final ScrollController scrollController;
  final int lineCount;
  final Set<int> activeLines;
  final HighlightController controller;
  final bool isReadOnly;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;

  const _CodeFieldBody({
    required this.scrollController,
    required this.lineCount,
    required this.activeLines,
    required this.controller,
    required this.isReadOnly,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LineNumbersGutter(lineCount: lineCount, activeLines: activeLines),
          Expanded(
            child: _HorizontalCodeScroll(
              controller: controller,
              isReadOnly: isReadOnly,
              focusNode: focusNode,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

final class _HorizontalCodeScroll extends StatelessWidget {
  final HighlightController controller;
  final bool isReadOnly;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;

  const _HorizontalCodeScroll({
    required this.controller,
    required this.isReadOnly,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: IntrinsicWidth(
            child: Padding(
              padding: _editorContentPadding,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: isReadOnly,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: resolveAppTextStyle(context, AppTextVariant.codeEditor),
                cursorColor: theme.editor.caret,
                cursorWidth: EditorMetricsTokens.editorCaretWidth,
                decoration: _editorInputDecoration,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _editorContentPadding = EdgeInsets.symmetric(
  horizontal: EditorMetricsTokens.editorContentPaddingLeft,
  vertical: EditorMetricsTokens.editorContentPaddingTop,
);

const _editorInputDecoration = InputDecoration(
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  isDense: true,
  contentPadding: EdgeInsets.zero,
);
