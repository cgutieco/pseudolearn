import 'package:flutter/material.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/icon_metrics.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import 'task_event_selection.dart';
import 'task_event_sentence.dart';
import 'task_event_tone.dart';
import 'task_labels.dart';
import 'task_live_button.dart';

final class TaskEventNarrationBar extends StatelessWidget {
  final ExecutionHistoryState state;
  final TaskFlowScene flow;
  final ValueChanged<SourceRange>? onSourceSelected;
  final bool isCompact;

  const TaskEventNarrationBar({
    super.key,
    required this.state,
    required this.flow,
    required this.onSourceSelected,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    final stepper = _EventStepper(narration: this);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3),
      padding: EdgeInsets.only(
        bottom: isCompact ? SpacingTokens.spaceHalf : SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusLg),
        border: Border.all(color: colors.borders.subtle),
      ),
      child: isCompact
          ? stepper
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                stepper,
                _EventSentence(narration: this),
              ],
            ),
    );
  }
}

final class _EventStepper extends StatelessWidget {
  final TaskEventNarrationBar narration;

  const _EventStepper({required this.narration});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = narration.state;
    final selected = state.selectedEvent;
    final compact = narration.isCompact;
    return Row(
      children: [
        _StepButton(
          narration: narration,
          tooltip: l10n.executionPreviousEvent,
          icon: Icons.chevron_left,
          target: selected <= state.horizonFirst ? null : selected - 1,
        ),
        Expanded(
          child: compact
              ? _EventSentence(narration: narration)
              : _EventPosition(selected: selected, live: state.liveEvent),
        ),
        TaskLiveButton(followsLive: state.followsLive, isCompact: compact),
        _StepButton(
          narration: narration,
          tooltip: l10n.executionNextEvent,
          icon: Icons.chevron_right,
          target: selected >= state.liveEvent ? null : selected + 1,
        ),
      ],
    );
  }
}

final class _StepButton extends StatelessWidget {
  final TaskEventNarrationBar narration;
  final String tooltip;
  final IconData icon;
  final int? target;

  const _StepButton({
    required this.narration,
    required this.tooltip,
    required this.icon,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final eventIndex = target;
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: eventIndex == null
          ? null
          : () => selectTaskEvent(
              context: context,
              flow: narration.flow,
              eventIndex: eventIndex,
              onSourceSelected: narration.onSourceSelected,
            ),
    );
  }
}

final class _EventPosition extends StatelessWidget {
  final int selected;
  final int live;

  const _EventPosition({required this.selected, required this.live});

  @override
  Widget build(BuildContext context) => AppText(
    AppLocalizations.of(context)!.executionEventPosition(selected, live),
    variant: AppTextVariant.label,
    textAlign: TextAlign.center,
    maxLines: 1,
  );
}

final class _EventSentence extends StatelessWidget {
  final TaskEventNarrationBar narration;

  const _EventSentence({required this.narration});

  @override
  Widget build(BuildContext context) {
    final state = narration.state;
    final flow = narration.flow;
    final row = flow.rowOf(state.selectedEvent);
    if (row == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeExtension.of(context).colors;
    final tone = TaskEventTone.of(row.kind, colors);
    final sentence = taskEventSentence(
      l10n,
      row,
      (taskId) => taskNamedLabel(l10n, taskId, flow.nameOf(taskId)),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: narration.isCompact ? 0 : SpacingTokens.space4,
      ),
      child: Row(
        children: [
          Icon(tone.icon, size: IconMetricsTokens.iconSm, color: tone.color),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(
            child: _SentenceText(narration: narration, text: sentence),
          ),
        ],
      ),
    );
  }
}

final class _SentenceText extends StatelessWidget {
  final TaskEventNarrationBar narration;
  final String text;

  const _SentenceText({required this.narration, required this.text});

  @override
  Widget build(BuildContext context) {
    final state = narration.state;
    final position = AppLocalizations.of(
      context,
    )!.executionEventShort(state.selectedEvent, state.liveEvent);
    return Semantics(
      liveRegion: true,
      child: AppText(
        narration.isCompact ? '$position · $text' : text,
        variant: narration.isCompact
            ? AppTextVariant.bodySmall
            : AppTextVariant.bodyDefault,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
