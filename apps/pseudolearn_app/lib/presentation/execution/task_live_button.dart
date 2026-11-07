import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/icon_metrics.dart';

final class TaskLiveButton extends StatelessWidget {
  final bool followsLive;
  final bool isCompact;

  const TaskLiveButton({
    super.key,
    required this.followsLive,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    final label = AppLocalizations.of(context)!.executionLive;
    final onPressed = followsLive
        ? null
        : () => context.read<ExecutionHistoryCubit>().dispatch(
            const FollowCurrentHistoryEvent(),
          );
    final dot = Icon(
      Icons.circle,
      size: IconMetricsTokens.iconXs / 2,
      color: followsLive ? colors.severities.success.fg : colors.text.link,
    );
    return isCompact
        ? IconButton(tooltip: label, onPressed: onPressed, icon: dot)
        : TextButton.icon(onPressed: onPressed, icon: dot, label: Text(label));
  }
}
