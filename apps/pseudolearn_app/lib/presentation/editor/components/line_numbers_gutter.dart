import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class LineNumbersGutter extends StatelessWidget {
  final int lineCount;
  final Set<int> activeLines;

  const LineNumbersGutter({super.key, required this.lineCount, this.activeLines = const {}});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space2),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        border: Border(right: BorderSide(color: theme.colors.borders.subtle, width: 1)),
      ),
      child: Column(
        children: [
          for (var i = 1; i <= lineCount; i++)
            _GutterLineItem(lineNumber: i, isCurrent: activeLines.contains(i)),
        ],
      ),
    );
  }
}

final class _GutterLineItem extends StatelessWidget {
  final int lineNumber;
  final bool isCurrent;

  const _GutterLineItem({required this.lineNumber, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final textStyle = resolveAppTextStyle(context, AppTextVariant.codeEditor);
    final lineHeight = textStyle.fontSize! * (textStyle.height ?? 1.0);
    final fg = isCurrent ? theme.colors.text.primary : theme.colors.text.tertiary;

    return Container(
      height: lineHeight,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: SpacingTokens.space2),
      color: isCurrent ? theme.colors.surfaces.brandSubtle : null,
      child: Text(
        '$lineNumber',
        style: TextStyle(
          fontFamily: textStyle.fontFamily,
          fontFamilyFallback: textStyle.fontFamilyFallback,
          fontSize: 12,
          color: fg,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
