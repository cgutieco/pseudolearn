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
  final selection = _lastCharacterSelection(text, position);
  if (selection == null) return null;
  final span = editable.text;
  if (span == null) return null;
  final baseline = _lineBaseline(
    editable: editable,
    span: span,
    position: position,
    selection: selection,
    typography: typography,
  );
  if (baseline == null) return null;
  final suggestion = _painter(ghost, typography);
  try {
    return Offset(
      editable.getLocalRectForCaret(position).left,
      baseline - suggestion.computeLineMetrics().first.baseline,
    );
  } finally {
    suggestion.dispose();
  }
}

TextSelection? _lastCharacterSelection(String text, TextPosition position) {
  final range = CharacterRange.at(text, position.offset);
  if (!range.moveBack()) return null;
  final probe = range.current;
  if (probe.contains('\n') || probe.contains('\r')) return null;
  return TextSelection(
    baseOffset: position.offset - probe.length,
    extentOffset: position.offset,
  );
}

double? _lineBaseline({
  required RenderEditable editable,
  required InlineSpan span,
  required TextPosition position,
  required TextSelection selection,
  required EditorGhostTypography typography,
}) {
  final text = span.toPlainText();
  final lineIndex = '\n'.allMatches(text.substring(0, position.offset)).length;
  final document = _painterFor(span, typography);
  try {
    final lines = document.computeLineMetrics();
    final documentBoxes = document.getBoxesForSelection(
      selection,
      boxHeightStyle: editable.selectionHeightStyle,
      boxWidthStyle: editable.selectionWidthStyle,
    );
    final editableBoxes = editable.getBoxesForSelection(selection);
    if (lineIndex >= lines.length ||
        documentBoxes.isEmpty ||
        editableBoxes.isEmpty) {
      return null;
    }
    return lines[lineIndex].baseline +
        editableBoxes.last.top -
        documentBoxes.last.top;
  } finally {
    document.dispose();
  }
}

TextPainter _painterFor(InlineSpan span, EditorGhostTypography typography) =>
    TextPainter(
      text: span,
      textDirection: typography.direction,
      textScaler: typography.scaler,
      strutStyle: typography.strut,
      textHeightBehavior: typography.heightBehavior,
      locale: typography.locale,
    )..layout();

TextPainter _painter(String text, EditorGhostTypography typography) =>
    TextPainter(
      text: TextSpan(text: text, style: typography.style),
      textDirection: typography.direction,
      textScaler: typography.scaler,
      strutStyle: typography.strut,
      textHeightBehavior: typography.heightBehavior,
      locale: typography.locale,
    )..layout();
