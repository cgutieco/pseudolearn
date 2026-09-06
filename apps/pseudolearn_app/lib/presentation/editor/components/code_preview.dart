import 'package:flutter/widgets.dart';
import '../../../domain/model/analysis/highlight_span.dart';
import '../../../domain/model/execution/execution_focus.dart';
import '../code_field.dart';
import '../highlight_controller.dart';

final class CodePreview extends StatefulWidget {
  final String text;
  final List<HighlightSpan> highlightSpans;
  final ExecutionFocus? focus;
  final Set<int> activeLines;

  const CodePreview({
    super.key,
    required this.text,
    this.highlightSpans = const [],
    this.focus,
    this.activeLines = const {},
  });

  @override
  State<CodePreview> createState() => _CodePreviewState();
}

final class _CodePreviewState extends State<CodePreview> {
  late final HighlightController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HighlightController(text: widget.text);
  }

  @override
  void didUpdateWidget(CodePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _controller.text = widget.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CodeField(
      controller: _controller,
      highlightSpans: widget.highlightSpans,
      focus: widget.focus,
      activeLines: widget.activeLines,
      isReadOnly: true,
    );
  }
}
