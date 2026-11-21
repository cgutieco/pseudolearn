import 'package:material_ui/material_ui.dart';

import '../../../domain/model/execution/output_line.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class OutputLineRow extends StatelessWidget {
  final OutputLine line;

  const OutputLineRow({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final target = line.target;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.spaceHalf),
      child: switch (line.kind) {
        OutputLineKind.rejectedInput => _AssignmentRow(
          line: line,
          target: target ?? '',
          isRejected: true,
        ),
        OutputLineKind.userInputEcho when target != null => _AssignmentRow(
          line: line,
          target: target,
          isRejected: false,
        ),
        _ => _PlainRow(line: line),
      },
    );
  }
}

final class _PlainRow extends StatelessWidget {
  final OutputLine line;

  const _PlainRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final isInput = line.kind == OutputLineKind.userInputEcho;
    final color = switch (line.kind) {
      OutputLineKind.programError => theme.colors.severities.error.fg,
      OutputLineKind.userInputEcho => theme.colors.text.secondary,
      _ => theme.colors.text.primary,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isInput) ...[
          Icon(
            Icons.arrow_forward,
            size: IconMetricsTokens.iconXs,
            color: theme.colors.text.secondary,
          ),
          const SizedBox(width: SpacingTokens.space2),
        ],
        Expanded(
          child: AppText(
            line.text,
            variant: AppTextVariant.codeEditor,
            color: color,
          ),
        ),
      ],
    );
  }
}

final class _AssignmentRow extends StatelessWidget {
  final OutputLine line;
  final String target;
  final bool isRejected;

  const _AssignmentRow({
    required this.line,
    required this.target,
    required this.isRejected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        AppText(
          '$target <- ',
          variant: AppTextVariant.codeEditor,
          color: theme.colors.text.secondary,
        ),
        Flexible(
          child: _AssignedValue(text: line.text, isRejected: isRejected),
        ),
        const SizedBox(width: SpacingTokens.space2),
        _AssignmentTag(line: line, isRejected: isRejected),
      ],
    );
  }
}

final class _AssignmentTag extends StatelessWidget {
  final OutputLine line;
  final bool isRejected;

  const _AssignmentTag({required this.line, required this.isRejected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final sourceLine = line.sourceLine;
    final text = isRejected
        ? l10n.outputRejectedTag
        : sourceLine == null
        ? ''
        : l10n.readLineLocation(sourceLine);
    return AppText(
      text,
      variant: AppTextVariant.caption,
      color: isRejected
          ? theme.colors.severities.error.fg
          : theme.colors.text.tertiary,
    );
  }
}

final class _AssignedValue extends StatelessWidget {
  final String text;
  final bool isRejected;

  const _AssignedValue({required this.text, required this.isRejected});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final style = resolveAppTextStyle(
      context,
      AppTextVariant.codeEditor,
      color: isRejected
          ? theme.colors.text.tertiary
          : theme.colors.text.primary,
    );
    return Text(
      text,
      style: isRejected
          ? style.copyWith(decoration: TextDecoration.lineThrough)
          : style,
    );
  }
}
