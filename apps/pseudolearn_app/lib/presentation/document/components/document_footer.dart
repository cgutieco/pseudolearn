import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../../application/trace/trace_cubit.dart';
import '../../../application/trace/trace_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import 'execution_stepper.dart';
import 'output_panel.dart';
import 'tracking_strip.dart';
import 'execution_options_sheet.dart';
import 'run_outcome.dart';

final class DocumentFooter extends StatelessWidget {
  final void Function(EditorState, StepPace) onPace;
  final VoidCallback onStop;
  final VoidCallback onToggleOutput;

  const DocumentFooter({
    super.key,
    required this.onPace,
    required this.onStop,
    required this.onToggleOutput,
  });

  @override
  Widget build(BuildContext context) => _FooterVisibility(
    onPace: onPace,
    onStop: onStop,
    onToggleOutput: onToggleOutput,
  );
}

final class _FooterVisibility extends StatelessWidget {
  final void Function(EditorState, StepPace) onPace;
  final VoidCallback onStop;
  final VoidCallback onToggleOutput;

  const _FooterVisibility({
    required this.onPace,
    required this.onStop,
    required this.onToggleOutput,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    if (canvas.deviceClass == DeviceClass.compact && canvas.isKeyboardVisible) {
      return const SizedBox.shrink();
    }
    return _FooterBody(
      onPace: onPace,
      onStop: onStop,
      onToggleOutput: onToggleOutput,
    );
  }
}

final class _FooterBody extends StatelessWidget {
  final void Function(EditorState, StepPace) onPace;
  final VoidCallback onStop;
  final VoidCallback onToggleOutput;

  const _FooterBody({
    required this.onPace,
    required this.onStop,
    required this.onToggleOutput,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, editorState) {
        return BlocBuilder<ExecutionCubit, ExecutionState>(
          builder: (context, execState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CompactTrackingStrip(isVisible: execState.isInFlight),
                _FooterCommands(
                  editorState: editorState,
                  executionState: execState,
                  onPace: onPace,
                  onStop: onStop,
                  onToggleOutput: onToggleOutput,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

final class _FooterCommands extends StatelessWidget {
  final EditorState editorState;
  final ExecutionState executionState;
  final void Function(EditorState, StepPace) onPace;
  final VoidCallback onStop;
  final VoidCallback onToggleOutput;

  const _FooterCommands({
    required this.editorState,
    required this.executionState,
    required this.onPace,
    required this.onStop,
    required this.onToggleOutput,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      OutputPanel(
        outputLines: executionState.outputLines,
        isExpanded: executionState.isOutputPanelExpanded,
        isStale: executionState.isOutputStale,
        onToggle: onToggleOutput,
        outcome: runOutcomeOf(executionState, AppLocalizations.of(context)!),
        onOutcomeTap: _revealHaltSite(context),
      ),
      ExecutionStepper(
        state: executionState,
        isExecutable: editorState.report.isExecutable,
        onPace: (pace) => onPace(editorState, pace),
        onTaskStep: (taskId) =>
            context.read<ExecutionCubit>().advanceTask(taskId: taskId),
        onStop: onStop,
        hasArguments:
            editorState.document?.executionArguments.isNotEmpty ?? false,
        onOpenOptions: () => showExecutionOptionsSheet(context),
      ),
    ],
  );

  VoidCallback? _revealHaltSite(BuildContext context) {
    final range = executionState.currentStep.focus?.range;
    if (executionState.status != ExecutionStatus.haltedWithError ||
        range == null) {
      return null;
    }
    return () => context.read<EditorCubit>().revealSource(range);
  }
}

final class _CompactTrackingStrip extends StatelessWidget {
  final bool isVisible;

  const _CompactTrackingStrip({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    final isCompact =
        DesignCanvasScope.of(context).deviceClass == DeviceClass.compact;
    if (!isCompact || !isVisible) return const SizedBox.shrink();

    return BlocBuilder<TraceCubit, TraceState>(
      builder: (context, traceState) => TrackingStrip(
        changedNames: traceState.changedNames,
        changedValues: traceState.changedValues,
      ),
    );
  }
}
