import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
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

final class TaskEventNarrationBar extends StatelessWidget {
  final ExecutionHistoryState state;
  final TaskFlowScene flow;
  final ValueChanged<SourceRange>? onSourceSelected;

  const TaskEventNarrationBar({
    super.key,
    required this.state,
    required this.flow,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3),
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      decoration: BoxDecoration(
        color: colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusLg),
        border: Border.all(color: colors.borders.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EventStepper(
            state: state,
            flow: flow,
            onSourceSelected: onSourceSelected,
          ),
          _EventSentence(row: flow.rowOf(state.selectedEvent), flow: flow),
        ],
      ),
    );
  }
}

final class _EventStepper extends StatelessWidget {
  final ExecutionHistoryState state;
  final TaskFlowScene flow;
  final ValueChanged<SourceRange>? onSourceSelected;

  const _EventStepper({
    required this.state,
    required this.flow,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = state.selectedEvent;
    return Row(
      children: [
        IconButton(
          tooltip: l10n.executionPreviousEvent,
          icon: const Icon(Icons.chevron_left),
          onPressed: selected <= state.horizonFirst
              ? null
              : () => _select(context, selected - 1),
        ),
        Expanded(
          child: _EventPosition(selected: selected, live: state.liveEvent),
        ),
        _LiveButton(followsLive: state.followsLive),
        IconButton(
          tooltip: l10n.executionNextEvent,
          icon: const Icon(Icons.chevron_right),
          onPressed: selected >= state.liveEvent
              ? null
              : () => _select(context, selected + 1),
        ),
      ],
    );
  }

  void _select(BuildContext context, int eventIndex) => selectTaskEvent(
    context: context,
    flow: flow,
    eventIndex: eventIndex,
    onSourceSelected: onSourceSelected,
  );
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

final class _LiveButton extends StatelessWidget {
  final bool followsLive;

  const _LiveButton({required this.followsLive});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return TextButton.icon(
      onPressed: followsLive
          ? null
          : () => context.read<ExecutionHistoryCubit>().dispatch(
              const FollowCurrentHistoryEvent(),
            ),
      icon: Icon(
        Icons.circle,
        size: IconMetricsTokens.iconXs / 2,
        color: followsLive
            ? colors.severities.success.fg
            : colors.text.tertiary,
      ),
      label: Text(AppLocalizations.of(context)!.executionLive),
    );
  }
}

final class _EventSentence extends StatelessWidget {
  final TaskFlowRow? row;
  final TaskFlowScene flow;

  const _EventSentence({required this.row, required this.flow});

  @override
  Widget build(BuildContext context) {
    final current = row;
    if (current == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final tone = TaskEventTone.of(
      current.kind,
      AppThemeExtension.of(context).colors,
    );
    final sentence = taskEventSentence(
      l10n,
      current,
      (taskId) => taskNamedLabel(l10n, taskId, flow.nameOf(taskId)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space4),
      child: Row(
        children: [
          Icon(tone.icon, size: IconMetricsTokens.iconSm, color: tone.color),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(child: _SentenceText(sentence: sentence)),
        ],
      ),
    );
  }
}

final class _SentenceText extends StatelessWidget {
  final String sentence;

  const _SentenceText({required this.sentence});

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AppText(
      sentence,
      variant: AppTextVariant.bodyDefault,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
