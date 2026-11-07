import 'package:flutter/material.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'task_event_sentence.dart';
import 'task_event_tone.dart';
import 'task_labels.dart';
import 'task_timeline_metrics.dart';
import 'task_timeline_painter.dart';

final class TaskTimelineRow extends StatelessWidget {
  final TaskFlowRow row;
  final int columnCount;
  final double columnWidth;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskTimelineRow({
    super.key,
    required this.row,
    required this.columnCount,
    required this.columnWidth,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeExtension.of(context).colors;
    final sentence = taskEventSentence(
      l10n,
      row,
      (taskId) => taskShortLabel(l10n, taskId),
    );
    return Semantics(
      button: true,
      selected: isSelected,
      label: l10n.executionEventSemantics(
        row.event.index,
        row.taskId,
        sentence,
        row.event.line,
      ),
      child: Material(
        color: isSelected ? colors.surfaces.brandSubtle : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: _RowContent(row: this, sentence: sentence),
        ),
      ),
    );
  }
}

final class _RowContent extends StatelessWidget {
  final TaskTimelineRow row;
  final String sentence;

  const _RowContent({required this.row, required this.sentence});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _EventIndex(index: row.row.event.index, isSelected: row.isSelected),
      _TaskTimelineLanes(
        row: row.row,
        columnCount: row.columnCount,
        columnWidth: row.columnWidth,
      ),
      Expanded(
        child: _RowSentence(sentence: sentence, row: row.row),
      ),
    ],
  );
}

final class _EventIndex extends StatelessWidget {
  final int index;
  final bool isSelected;

  const _EventIndex({required this.index, required this.isSelected});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: TaskTimelineMetrics.indexWidth,
    child: AppText(
      index.toString(),
      variant: isSelected ? AppTextVariant.label : AppTextVariant.codeCaption,
      textAlign: TextAlign.center,
      maxLines: 1,
    ),
  );
}

final class _TaskTimelineLanes extends StatelessWidget {
  final TaskFlowRow row;
  final int columnCount;
  final double columnWidth;

  const _TaskTimelineLanes({
    required this.row,
    required this.columnCount,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    final tone = TaskEventTone.of(row.kind, colors);
    return CustomPaint(
      size: Size(columnCount * columnWidth, TaskTimelineMetrics.rowHeight),
      painter: TaskTimelinePainter(
        row: row,
        columnCount: columnCount,
        columnWidth: columnWidth,
        palette: TaskTimelinePalette(
          lane: colors.borders.subtle,
          dot: tone.color,
          link: tone.color,
          hollow: colors.surfaces.canvas,
        ),
      ),
    );
  }
}

final class _RowSentence extends StatelessWidget {
  final String sentence;
  final TaskFlowRow row;

  const _RowSentence({required this.sentence, required this.row});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      left: SpacingTokens.space2,
      right: SpacingTokens.space3,
    ),
    child: AppText(
      sentence,
      variant: row.kind.isQuiet
          ? AppTextVariant.caption
          : AppTextVariant.bodySmall,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
