import 'package:material_ui/material_ui.dart';
import '../../../domain/model/execution/output_line.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/component_metrics.dart';
import 'run_outcome.dart';
import 'run_outcome_note.dart';
import 'run_result_pill.dart';
import 'output_line_row.dart';

final class OutputPanel extends StatelessWidget {
  final List<OutputLine> outputLines;
  final bool isExpanded;
  final bool isStale;
  final VoidCallback onToggle;
  final RunOutcome? outcome;
  final VoidCallback? onOutcomeTap;
  final Widget? pendingRead;

  const OutputPanel({
    super.key,
    required this.outputLines,
    required this.isExpanded,
    this.isStale = false,
    required this.onToggle,
    this.outcome,
    this.onOutcomeTap,
    this.pendingRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final isOpen = isExpanded || pendingRead != null;
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        border: Border(
            top: BorderSide(color: theme.colors.borders.subtle, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OutputPanelHeader(
            lineCount: outputLines.length,
            isExpanded: isOpen,
            isStale: isStale,
            onToggle: onToggle,
            outcome: outcome,
            onOutcomeTap: onOutcomeTap,
          ),
          if (isOpen)
            _OutputContentBox(
                outputLines: outputLines, outcome: outcome, pendingRead: pendingRead),
        ],
      ),
    );
  }
}

final class _OutputPanelHeader extends StatelessWidget {
  final int lineCount;
  final bool isExpanded;
  final bool isStale;
  final VoidCallback onToggle;
  final RunOutcome? outcome;
  final VoidCallback? onOutcomeTap;

  const _OutputPanelHeader({
    required this.lineCount,
    required this.isExpanded,
    required this.isStale,
    required this.onToggle,
    required this.outcome,
    required this.onOutcomeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = outcome;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      child: Row(
        children: [
          Expanded(
              child:
                  _OutputPanelSummary(lineCount: lineCount, isStale: isStale)),
          if (result != null)
            RunResultPill(outcome: result, onTap: onOutcomeTap),
          const SizedBox(width: SpacingTokens.space1),
          AppIconButton(
            icon: isExpanded
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_up,
            semanticLabel: isExpanded ? l10n.actionCollapse : l10n.actionExpand,
            variant: AppButtonVariant.tertiary,
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

final class _OutputPanelSummary extends StatelessWidget {
  final int lineCount;
  final bool isStale;

  const _OutputPanelSummary({required this.lineCount, required this.isStale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return Row(
      children: [
        Flexible(
            child: _EllipsizedLabel(
                text: l10n.outputPanelTitle, color: theme.colors.text.primary)),
        const SizedBox(width: SpacingTokens.space2),
        AppText(l10n.outputLinesCount(lineCount),
            variant: AppTextVariant.codeCaption,
            color: theme.colors.text.secondary),
        if (isStale) ...[
          const SizedBox(width: SpacingTokens.space2),
          Flexible(
            child: _EllipsizedLabel(
              text: '(${l10n.outputPreviousExecution})',
              color: theme.colors.text.tertiary,
              variant: AppTextVariant.caption,
            ),
          ),
        ],
      ],
    );
  }
}

final class _EllipsizedLabel extends StatelessWidget {
  final String text;
  final Color color;
  final AppTextVariant variant;

  const _EllipsizedLabel(
      {required this.text,
      required this.color,
      this.variant = AppTextVariant.label});

  @override
  Widget build(BuildContext context) {
    return AppText(text,
        variant: variant,
        color: color,
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }
}

final class _OutputContentBox extends StatelessWidget {
  final List<OutputLine> outputLines;
  final RunOutcome? outcome;
  final Widget? pendingRead;

  const _OutputContentBox({
    required this.outputLines,
    required this.outcome,
    required this.pendingRead,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final read = pendingRead;
    return SizedBox(
      height: ComponentMetricsTokens.outputPanelBodyHeight,
      child: read != null
          ? _ConsoleAwaitingRead(outputLines: outputLines, read: read)
          : outputLines.isEmpty && outcome?.note == null
          ? Center(
              child: AppText(l10n.outputEmpty,
                  variant: AppTextVariant.caption,
                  color: theme.colors.text.tertiary),
            )
          : ListView.builder(
              padding: _consolePadding,
              itemCount: outputLines.length + (outcome?.note == null ? 0 : 1),
              itemBuilder: (context, index) => index < outputLines.length
                  ? OutputLineRow(line: outputLines[index])
                  : RunOutcomeNote(outcome: outcome!),
            ),
    );
  }
}

const EdgeInsets _consolePadding = EdgeInsets.symmetric(
  horizontal: SpacingTokens.space4,
  vertical: SpacingTokens.space2,
);

final class _ConsoleAwaitingRead extends StatelessWidget {
  final List<OutputLine> outputLines;
  final Widget read;

  const _ConsoleAwaitingRead({required this.outputLines, required this.read});

  @override
  Widget build(BuildContext context) => ListView.builder(
    reverse: true,
    padding: _consolePadding,
    itemCount: outputLines.length + 1,
    itemBuilder: (context, index) => index == 0
        ? KeyedSubtree(key: const ValueKey('pending-read'), child: read)
        : OutputLineRow(line: outputLines[outputLines.length - index]),
  );
}
