import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/execution/task_flow_scene.dart';

void selectTaskEvent({
  required BuildContext context,
  required TaskFlowScene flow,
  required int eventIndex,
  required ValueChanged<SourceRange>? onSourceSelected,
}) {
  context.read<ExecutionHistoryCubit>().dispatch(
    SelectHistoryEvent(eventIndex),
  );
  final range = flow.rowOf(eventIndex)?.event.sourceRange;
  if (range != null) onSourceSelected?.call(range);
}
