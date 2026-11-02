import 'package:flutter/material.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';

final class ExecutionHistoryNavigation extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionHistoryCubit cubit;

  const ExecutionHistoryNavigation({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _PreviousHistoryRange(state: state, cubit: cubit),
      Expanded(child: _HistoryRangeLabel(state: state)),
      _NextHistoryRange(state: state, cubit: cubit),
      _FollowLiveHistory(cubit: cubit, followsLive: state.followsLive),
    ],
  );
}

final class _PreviousHistoryRange extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionHistoryCubit cubit;

  const _PreviousHistoryRange({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = _rangeCount(state);
    return IconButton(
      tooltip: l10n.executionPreviousRange,
      onPressed: state.rangeStart <= state.horizonFirst
          ? null
          : () => cubit.dispatch(
              SelectHistoryRange(
                _previousStart(state, count),
                _previousCount(state, count),
              ),
            ),
      icon: const Icon(Icons.chevron_left),
    );
  }
}

final class _HistoryRangeLabel extends StatelessWidget {
  final ExecutionHistoryState state;

  const _HistoryRangeLabel({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppText(
      l10n.executionHistoryRange(
        state.rangeStart,
        state.rangeEnd,
        state.liveEvent,
      ),
      variant: AppTextVariant.label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

final class _NextHistoryRange extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionHistoryCubit cubit;

  const _NextHistoryRange({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = _rangeCount(state);
    return IconButton(
      tooltip: l10n.executionNextRange,
      onPressed: state.rangeEnd >= state.liveEvent
          ? null
          : () => cubit.dispatch(
              SelectHistoryRange(state.rangeEnd + 1, _nextCount(state, count)),
            ),
      icon: const Icon(Icons.chevron_right),
    );
  }
}

final class _FollowLiveHistory extends StatelessWidget {
  final ExecutionHistoryCubit cubit;
  final bool followsLive;

  const _FollowLiveHistory({required this.cubit, required this.followsLive});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.executionFollowLive,
      onPressed: followsLive
          ? null
          : () => cubit.dispatch(const FollowCurrentHistoryEvent()),
      icon: const Icon(Icons.vertical_align_bottom),
    );
  }
}

int _rangeCount(ExecutionHistoryState state) =>
    state.rangeEnd >= state.rangeStart
    ? state.rangeEnd - state.rangeStart + 1
    : 1;

int _previousStart(ExecutionHistoryState state, int count) {
  final end = state.rangeStart - 1;
  final candidate = end - count + 1;
  return candidate < state.horizonFirst ? state.horizonFirst : candidate;
}

int _previousCount(ExecutionHistoryState state, int count) {
  final start = _previousStart(state, count);
  return state.rangeStart - start;
}

int _nextCount(ExecutionHistoryState state, int count) {
  final remaining = state.liveEvent - state.rangeEnd;
  return remaining < count ? remaining : count;
}
