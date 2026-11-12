import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/execution/task_structure_scene.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/border_metrics.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import 'task_labels.dart';
import 'task_status_badge.dart';
import 'task_status_hint.dart';

final class TaskStateCard extends StatelessWidget {
  final TaskStructureNode task;
  final TaskStructureScene scene;
  final bool isEventTask;

  const TaskStateCard({
    super.key,
    required this.task,
    required this.scene,
    required this.isEventTask,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Padding(
      padding: EdgeInsets.only(
        left: task.depth * SpacingTokens.space5,
        bottom: SpacingTokens.space2,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.space3,
          SpacingTokens.space3,
          SpacingTokens.space3,
          SpacingTokens.space1,
        ),
        decoration: BoxDecoration(
          color: colors.surfaces.defaultSurface,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
          border: Border.all(
            color: isEventTask ? colors.borders.focus : colors.borders.subtle,
            width: isEventTask
                ? BorderMetricsTokens.widthEmphasis
                : BorderMetricsTokens.widthHairline,
          ),
        ),
        child: _TaskStateCardBody(task: task, scene: scene),
      ),
    );
  }
}

final class _TaskStateCardBody extends StatelessWidget {
  final TaskStructureNode task;
  final TaskStructureScene scene;

  const _TaskStateCardBody({required this.task, required this.scene});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hint = taskStatusHint(l10n, task, scene);
    final parent = task.parentId;
    final created = task.createdAtEvent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardTitle(task: task),
        if (hint != null)
          _CardLine(text: hint, variant: AppTextVariant.bodySmall),
        if (parent != null && created != null)
          _CardLine(
            text: l10n.executionLaunchedBy(
              taskNamedLabel(l10n, parent, scene.nameOf(parent)),
              created,
            ),
            variant: AppTextVariant.caption,
          ),
        _TaskCardActions(task: task),
      ],
    );
  }
}

final class _CardTitle extends StatelessWidget {
  final TaskStructureNode task;

  const _CardTitle({required this.task});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: AppText(
          taskNamedLabel(AppLocalizations.of(context)!, task.taskId, task.name),
          variant: AppTextVariant.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      TaskStatusBadge(status: task.status),
    ],
  );
}

final class _CardLine extends StatelessWidget {
  final String text;
  final AppTextVariant variant;

  const _CardLine({required this.text, required this.variant});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: SpacingTokens.space1),
    child: AppText(text, variant: variant),
  );
}

final class _TaskCardActions extends StatelessWidget {
  final TaskStructureNode task;

  const _TaskCardActions({required this.task});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ExecutionHistoryCubit>();
    final created = task.createdAtEvent;
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        if (created != null)
          TextButton(
            onPressed: () => cubit.dispatch(SelectHistoryEvent(created)),
            child: Text(l10n.executionGoToCreation),
          ),
        TextButton(
          onPressed: () => cubit
            ..dispatch(SelectHistoryTask(task.taskId))
            ..dispatch(
              const SelectHistorySurface(ExecutionHistorySurface.events),
            ),
          child: Text(l10n.executionShowVariables),
        ),
      ],
    );
  }
}
