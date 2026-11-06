import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../domain/model/analysis/source_range.dart';
import 'keyword_help_chip.dart';
import 'keyword_help_geometry.dart';

final class KeywordHelpLayer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String sourceCode;
  final SourceRange? keyword;
  final ValueChanged<SourceRange> onExplain;
  final Widget child;

  const KeywordHelpLayer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.sourceCode,
    required this.keyword,
    required this.onExplain,
    required this.child,
  });

  @override
  State<KeywordHelpLayer> createState() => _KeywordHelpLayerState();
}

final class _KeywordHelpLayerState extends State<KeywordHelpLayer> {
  Rect? _rect;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    widget.focusNode.addListener(_refresh);
  }

  @override
  void didUpdateWidget(KeywordHelpLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_refresh);
      widget.focusNode.addListener(_refresh);
    }
    _scheduleMeasure();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.focusNode.removeListener(_refresh);
    super.dispose();
  }

  SourceRange? get _restingKeyword {
    final keyword = widget.keyword;
    final value = widget.controller.value;
    final isResting =
        keyword != null &&
        widget.focusNode.hasFocus &&
        value.text == widget.sourceCode &&
        value.selection.isValid &&
        value.selection.isCollapsed &&
        keyword.containsOffset(value.selection.baseOffset);
    return isResting ? keyword : null;
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

  void _scheduleMeasure() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

  void _measure() {
    if (!mounted) return;
    final keyword = _restingKeyword;
    final editable = widget.focusNode.context
        ?.findAncestorStateOfType<EditableTextState>();
    final box = context.findRenderObject();
    final rect = keyword == null || editable == null || box is! RenderBox
        ? null
        : measureKeywordRect(
            editable: editable.renderEditable,
            overlay: box,
            keyword: keyword,
          );
    if (rect != _rect) setState(() => _rect = rect);
  }

  bool _onScroll(ScrollNotification notification) {
    _scheduleMeasure();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _restingKeyword;
    final rect = _rect;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: widget.child),
          if (keyword != null && rect != null)
            _ChipPlacement(
              rect: rect,
              onPressed: () => widget.onExplain(keyword),
            ),
        ],
      ),
    );
  }
}

final class _ChipPlacement extends StatelessWidget {
  final Rect rect;
  final VoidCallback onPressed;

  const _ChipPlacement({required this.rect, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spot = keywordChipSpot(rect, constraints.biggest);
          return Stack(
            children: [
              Positioned(
                left: spot.dx,
                top: spot.dy,
                child: TextFieldTapRegion(
                  child: KeywordHelpChip(onPressed: onPressed),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
