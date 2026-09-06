import 'package:flutter/material.dart';
import '../../domain/model/analysis/highlight_span.dart';
import '../../domain/model/analysis/source_range.dart';
import '../theme/tokens/syntax_colors.dart';

final class HighlightController extends TextEditingController {
  List<HighlightSpan> highlightSpans;
  AppSyntaxColors? syntaxColors;
  SourceRange? focusRange;
  Color? focusBackground;

  HighlightController({
    super.text,
    this.highlightSpans = const [],
    this.syntaxColors,
  });

  void updateSpans(List<HighlightSpan> spans) {
    highlightSpans = spans;
    notifyListeners();
  }

  void updateFocus(SourceRange? range) {
    if (range?.startOffset == focusRange?.startOffset &&
        range?.endOffset == focusRange?.endOffset) {
      return;
    }
    focusRange = range;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (highlightSpans.isEmpty || syntaxColors == null || text.isEmpty) {
      return TextSpan(text: text, style: style);
    }
    return TextSpan(
      children: _buildSpans(style),
      style: style,
    );
  }

  List<TextSpan> _buildSpans(TextStyle? style) {
    final children = <TextSpan>[];
    var currentOffset = 0;

    for (final span in highlightSpans) {
      if (span.range.startOffset < currentOffset) continue;
      if (span.range.startOffset > text.length) break;

      final start = span.range.startOffset.clamp(0, text.length);
      final end = span.range.endOffset.clamp(0, text.length);
      if (start > currentOffset) {
        _addSegments(children, start: currentOffset, end: start, style: style, color: null);
      }
      if (start < end) {
        _addSegments(children, start: start, end: end, style: style, color: _getColorForCategory(span.category, syntaxColors!));
        currentOffset = end;
      }
    }

    if (currentOffset < text.length) {
      _addSegments(children, start: currentOffset, end: text.length, style: style, color: null);
    }
    return children;
  }

  void _addSegments(
    List<TextSpan> children, {
    required int start,
    required int end,
    required TextStyle? style,
    required Color? color,
  }) {
    for (final cut in _cutsWithin(start, end)) {
      children.add(TextSpan(
        text: text.substring(cut.$1, cut.$2),
        style: _styled(style, color, cut.$1),
      ));
    }
  }

  List<(int, int)> _cutsWithin(int start, int end) {
    final range = focusRange;
    if (range == null) return [(start, end)];

    final low = _clampedInside(range.startOffset, start, end);
    final high = _clampedInside(range.endOffset, start, end);
    final cuts = <(int, int)>[];
    if (start < low) cuts.add((start, low));
    if (low < high) cuts.add((low, high));
    if (high < end) cuts.add((high, end));
    return cuts.isEmpty ? [(start, end)] : cuts;
  }

  int _clampedInside(int offset, int start, int end) {
    if (offset < start) return start;
    if (offset > end) return end;
    return offset;
  }

  TextStyle? _styled(TextStyle? style, Color? color, int offset) {
    final background = _isFocused(offset) ? focusBackground : null;
    final base = color == null ? style : (style?.copyWith(color: color) ?? TextStyle(color: color));
    if (background == null) return base;
    return (base ?? const TextStyle()).copyWith(backgroundColor: background);
  }

  bool _isFocused(int offset) {
    final range = focusRange;
    return range != null && offset >= range.startOffset && offset < range.endOffset;
  }

  Color _getColorForCategory(HighlightCategory category, AppSyntaxColors colors) {
    return switch (category) {
      HighlightCategory.keywordStructured => colors.keywordStructured,
      HighlightCategory.keywordProcedural => colors.keywordProcedural,
      HighlightCategory.keywordOop => colors.keywordOop,
      HighlightCategory.type => colors.keywordStructured,
      HighlightCategory.literalNumber => colors.literalNumber,
      HighlightCategory.literalString => colors.literalText,
      HighlightCategory.literalBoolean => colors.literalBoolean,
      HighlightCategory.operator => colors.ink,
      HighlightCategory.punctuation => colors.ink,
      HighlightCategory.comment => colors.comment,
      HighlightCategory.identifier => colors.identifier,
    };
  }
}
