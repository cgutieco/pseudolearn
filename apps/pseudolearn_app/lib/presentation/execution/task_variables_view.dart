import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/execution/execution_value_page.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/border_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'execution_value_text.dart';
import 'task_selector_chips.dart';

final class TaskVariablesView extends StatelessWidget {
  final ExecutionHistoryState state;
  final TaskFlowScene flow;

  const TaskVariablesView({super.key, required this.state, required this.flow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inspection = state.inspection;
    final isChannelEvent =
        state.selectedRecord?.eventClass.startsWith('channel_') ?? false;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.space3),
      children: [
        if (inspection == null)
          _Note(text: l10n.executionObservationUnavailable)
        else ...[
          TaskSelectorChips(state: state, inspection: inspection, flow: flow),
          TaskFrameBreadcrumb(state: state, inspection: inspection),
          if (isChannelEvent)
            _Note(text: l10n.executionChannelStateUnavailable),
          if (state.values.isEmpty) _Note(text: l10n.executionNoVariables),
          for (final entry in state.values) _TaskValueRow(entry: entry),
          if (state.canLoadMoreValues) const _TaskValuePageButton(),
        ],
      ],
    );
  }
}

final class _Note extends StatelessWidget {
  final String text;

  const _Note({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
    child: AppText(text, variant: AppTextVariant.bodySmall),
  );
}

final class _TaskValueRow extends StatelessWidget {
  final ExecutionValueEntry entry;

  const _TaskValueRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
      ),
      child: _ValueColumns(entry: entry),
    );
  }
}

final class _ValueColumns extends StatelessWidget {
  final ExecutionValueEntry entry;

  const _ValueColumns({required this.entry});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: AppText(entry.name, variant: AppTextVariant.bodyDefault),
      ),
      const SizedBox(width: SpacingTokens.space3),
      Expanded(
        flex: 3,
        child: AppText(
          executionValueText(AppLocalizations.of(context)!, entry.value),
          variant: AppTextVariant.codeInline,
        ),
      ),
    ],
  );
}

final class _TaskValuePageButton extends StatelessWidget {
  const _TaskValuePageButton();

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => context.read<ExecutionHistoryCubit>().dispatch(
      const LoadNextValuePage(),
    ),
    icon: const Icon(Icons.expand_more),
    label: Text(AppLocalizations.of(context)!.executionLoadMoreValues),
  );
}
