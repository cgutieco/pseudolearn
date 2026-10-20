import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef EditorGhostTypography = ({
  TextStyle style,
  TextScaler scaler,
  StrutStyle? strut,
  TextHeightBehavior? heightBehavior,
  TextDirection direction,
  Locale? locale,
});

typedef EditorAssistAnchor = ({
  Rect caret,
  Offset? ghostOrigin,
  EditorGhostTypography typography,
});

EditorAssistAnchor measureEditorAssist({
  required RenderEditable editable,
  required RenderBox overlay,
  required TextPosition position,
  required String? ghost,
}) {
  final caret = editable.getLocalRectForCaret(position);
  final typography = (
    style: editable.text?.style ?? const TextStyle(),
    scaler: editable.textScaler,
    strut: editable.strutStyle,
    heightBehavior: editable.textHeightBehavior,
    direction: editable.textDirection,
    locale: editable.locale,
  );
  final origin = _ghostOrigin(
    editable: editable,
    position: position,
    ghost: ghost,
    typography: typography,
  );
  return (
    caret:
        overlay.globalToLocal(editable.localToGlobal(caret.topLeft)) &
        caret.size,
    ghostOrigin: origin == null
        ? null
        : overlay.globalToLocal(editable.localToGlobal(origin)),
    typography: typography,
  );
}

Offset? _ghostOrigin({
  required RenderEditable editable,
  required TextPosition position,
  required String? ghost,
  required EditorGhostTypography typography,
}) {
  final text = editable.text?.toPlainText() ?? '';
  if (ghost == null ||
      ghost.isEmpty ||
      position.offset <= 0 ||
      position.offset > text.length) {
    return null;
  }
  final range = CharacterRange.at(text, position.offset);
  if (!range.moveBack()) return null;
  final probe = range.current;
  if (probe.contains('\n') || probe.contains('\r')) return null;
  final selection = TextSelection(
    baseOffset: position.offset - probe.length,
    extentOffset: position.offset,
  );
  final boxes = editable.getBoxesForSelection(selection);
  if (boxes.isEmpty) return null;
  final baseline = _probeBaseline(probe, typography, editable);
  if (baseline == null) return null;
  final suggestion = _painter(ghost, typography);
  try {
    return Offset(
      editable.getLocalRectForCaret(position).left,
      boxes.last.top +
          baseline -
          suggestion.computeLineMetrics().first.baseline,
    );
  } finally {
    suggestion.dispose();
  }
}

double? _probeBaseline(
  String probe,
  EditorGhostTypography typography,
  RenderEditable editable,
) {
  final sample = _painter(probe, typography);
  try {
    final boxes = sample.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: probe.length),
      boxHeightStyle: editable.selectionHeightStyle,
      boxWidthStyle: editable.selectionWidthStyle,
    );
    if (boxes.isEmpty) return null;
    return sample.computeLineMetrics().first.baseline - boxes.last.top;
  } finally {
    sample.dispose();
  }
}

TextPainter _painter(String text, EditorGhostTypography typography) =>
    TextPainter(
      text: TextSpan(text: text, style: typography.style),
      textDirection: typography.direction,
      textScaler: typography.scaler,
      strutStyle: typography.strut,
      textHeightBehavior: typography.heightBehavior,
      locale: typography.locale,
    )..layout();
