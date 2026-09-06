import 'dart:ui';
import 'color_primitives.dart';

final class EditorMetricsTokens {
  static const double editorGutterWidth = 48.0;
  static const double editorGutterWidthPerExtraDigit = 8.0;
  static const double editorGutterPadding = 8.0;
  static const double editorContentPaddingLeft = 12.0;
  static const double editorContentPaddingTop = 8.0;

  static const double editorLineHeightCompact = 22.0;
  static const double editorLineHeightMedium = 22.0;
  static const double editorLineHeightExpanded = 21.0;

  static const double editorCaretWidth = 2.0;
  static const Duration editorCaretBlinkPeriod = Duration(milliseconds: 1000);

  static const int editorIndentColumns = 4;
  static const double editorIndentGuideWidth = 1.0;

  static const double editorSquiggleStroke = 1.5;
  static const double editorSquiggleAmplitude = 1.5;
  static const double editorSquiggleWavelength = 6.0;

  static const double editorMarkerWidth = 3.0;
  static const double editorMarkerIconSize = 16.0;

  static const double editorBracketMatchBorderWidth = 1.0;

  static const double flowNodeWidth = 200.0;
  static const double flowNodeMinHeight = 48.0;
  static const double flowNodePadding = 12.0;
  static const double flowNodeGapVertical = 24.0;
  static const double flowNodeGapHorizontal = 32.0;
  static const double flowNodeRadiusProcess = 8.0;
  static const double flowNodeRadiusDecision = 0.0;
  static const double flowNodeRadiusIo = 0.0;
  static const double flowNodeRadiusTerminal = 9999.0;
  static const double flowNodeBorderWidth = 1.0;
  static const double flowNodeLayerAccentWidth = 3.0;
  static const double flowConnectorStroke = 1.5;
  static const double flowConnectorArrowLength = 8.0;
  static const double flowConnectorArrowWidth = 6.0;
  static const double flowExecutionActiveBorderWidth = 2.0;

  static const double traceHeaderHeight = 40.0;
  static const double traceStepColumnWidth = 64.0;
  static const double traceLineColumnWidth = 56.0;
  static const double traceScopeColumnWidth = 96.0;
  static const double traceVariableColumnWidth = 136.0;
  static const double traceRowHeightCompact = 40.0;
  static const double traceRowHeightMedium = 36.0;
  static const double traceRowHeightExpanded = 32.0;
  static const double traceCellPaddingX = 12.0;
  static const double traceCellPaddingY = 8.0;
  static const double traceColumnMinWidth = 88.0;
}

final class EditorColors {
  final Color surface;
  final Color gutterSurface;
  final Color gutterText;
  final Color gutterTextActive;
  final Color lineActive;
  final Color lineExecution;
  final Color selection;
  final Color caret;

  const EditorColors.light()
      : surface = ColorPrimitives.neutral0,
        gutterSurface = ColorPrimitives.neutral50,
        gutterText = ColorPrimitives.neutral500,
        gutterTextActive = ColorPrimitives.neutral900,
        lineActive = ColorPrimitives.neutral50,
        lineExecution = ColorPrimitives.brand50,
        selection = ColorPrimitives.brand100,
        caret = ColorPrimitives.brand600;

  const EditorColors.dark()
      : surface = ColorPrimitives.neutral1000,
        gutterSurface = ColorPrimitives.neutral1000,
        gutterText = ColorPrimitives.neutral600,
        gutterTextActive = ColorPrimitives.neutral100,
        lineActive = ColorPrimitives.neutral950,
        lineExecution = ColorPrimitives.brand950,
        selection = ColorPrimitives.brand900,
        caret = ColorPrimitives.brand400;
}
