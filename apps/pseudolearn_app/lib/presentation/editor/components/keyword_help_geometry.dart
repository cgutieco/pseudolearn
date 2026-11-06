import 'package:flutter/rendering.dart';
import '../../../domain/model/analysis/source_range.dart';
import '../../theme/tokens/component_metrics.dart';

Rect? measureKeywordRect({
  required RenderEditable editable,
  required RenderBox overlay,
  required SourceRange keyword,
}) {
  final length = editable.text?.toPlainText().length ?? 0;
  if (keyword.startOffset < 0 || keyword.endOffset > length) return null;
  final start = editable.getLocalRectForCaret(
    TextPosition(offset: keyword.startOffset),
  );
  final end = editable.getLocalRectForCaret(
    TextPosition(offset: keyword.endOffset),
  );
  final topLeft = overlay.globalToLocal(editable.localToGlobal(start.topLeft));
  final bottomRight = overlay.globalToLocal(
    editable.localToGlobal(Offset(end.left, start.bottom)),
  );
  return Rect.fromPoints(topLeft, bottomRight);
}

Offset keywordChipSpot(Rect keyword, Size available) {
  const size = ComponentMetricsTokens.keywordHelpChipSize;
  const gap = ComponentMetricsTokens.keywordHelpChipGap;
  final above = keyword.top - size - gap;
  final top = above >= 0 ? above : keyword.bottom + gap;
  final left = (keyword.center.dx - size / 2).clamp(
    0.0,
    (available.width - size).clamp(0.0, double.infinity),
  );
  return Offset(left, top);
}
