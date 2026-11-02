import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/execution/execution_value_page.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class TaskEventValuesHeading extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskEventValuesHeading({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.space4,
      vertical: SpacingTokens.space2,
    ),
    child: Align(
      alignment: Alignment.centerLeft,
      child: AppText(
        AppLocalizations.of(context)!.executionVariablesLabel(
          state.selectedEvent,
          state.selectedTaskId,
          state.selectedFrame,
        ),
        variant: AppTextVariant.label,
      ),
    ),
  );
}

final class TaskChannelStateNotice extends StatelessWidget {
  const TaskChannelStateNotice({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.space4,
      vertical: SpacingTokens.space1,
    ),
    child: AppText(
      AppLocalizations.of(context)!.executionChannelStateUnavailable,
      variant: AppTextVariant.caption,
    ),
  );
}

final class TaskEventValuesView extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskEventValuesView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.values.isEmpty && state.valueTotal == 0 && state.error == null) {
      return Center(
        child: AppText(
          AppLocalizations.of(context)!.executionNoVariables,
          variant: AppTextVariant.bodySmall,
        ),
      );
    }
    return ListView.builder(
      itemCount: state.values.length,
      itemBuilder: (context, index) =>
          _TaskValueRow(entry: state.values[index]),
    );
  }
}

final class _TaskValueRow extends StatelessWidget {
  final ExecutionValueEntry entry;

  const _TaskValueRow({required this.entry});

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    title: AppText(entry.name, variant: AppTextVariant.bodyDefault),
    subtitle: AppText(
      _valueText(context, entry),
      variant: AppTextVariant.codeInline,
    ),
  );
}

String _valueText(BuildContext context, ExecutionValueEntry entry) {
  final l10n = AppLocalizations.of(context)!;
  final value = entry.value;
  if (value['valor'] is String) return value['valor'] as String;
  if (value['sin_valor'] == true) return l10n.executionValueUndefined;
  if (value['nulo'] == true) return l10n.executionValueNull;
  if (value['ref'] is int) {
    return l10n.executionValueReference(value['ref'] as int);
  }
  return jsonEncode(value);
}

final class TaskEventValuePageButton extends StatelessWidget {
  const TaskEventValuePageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: () => context.read<ExecutionHistoryCubit>().dispatch(
        const LoadNextValuePage(),
      ),
      icon: const Icon(Icons.expand_more),
      label: Text(l10n.executionLoadMoreValues),
    );
  }
}
