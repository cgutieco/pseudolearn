import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'task_flow_scene_layer.dart';

final class TaskFlowCanvas extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskFlowCanvas({super.key, required this.state});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scene = context.read<ExecutionHistoryCubit>().projectFlow(
        width: constraints.maxWidth,
      );
      return Column(
        children: [
          const TaskFlowLegend(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: scene.width,
                height: scene.height,
                child: TaskFlowSceneLayer(
                  scene: scene,
                  selectedEvent: state.selectedEvent,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

final class TaskFlowLegend extends StatelessWidget {
  const TaskFlowLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      child: Wrap(
        spacing: SpacingTokens.space4,
        runSpacing: SpacingTokens.space1,
        children: [
          AppText(l10n.executionFlowAxis, variant: AppTextVariant.caption),
          AppText(
            l10n.executionFlowCreationLegend,
            variant: AppTextVariant.caption,
          ),
          AppText(
            l10n.executionFlowWaitLegend,
            variant: AppTextVariant.caption,
          ),
        ],
      ),
    );
  }
}
