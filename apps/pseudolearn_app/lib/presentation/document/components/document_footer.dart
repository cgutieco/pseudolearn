import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../../application/trace/trace_cubit.dart';
import '../../../application/trace/trace_state.dart';
import '../../shell/design_canvas.dart';
import '../../shell/device_class.dart';
import 'execution_stepper.dart';
import 'output_panel.dart';
import 'tracking_strip.dart';

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
                OutputPanel(
                  outputLines: execState.outputLines,
                  isExpanded: execState.isOutputPanelExpanded,
                  isStale: execState.isOutputStale,
                  onToggle: onToggleOutput,
                ),
                ExecutionStepper(
                  state: execState,
                  isExecutable: editorState.report.isExecutable,
                  onPace: (pace) => onPace(editorState, pace),
                  onStop: onStop,
                ),
              ],
            );
          },
        );
      },
    );
  }
}


final class _CompactTrackingStrip extends StatelessWidget {
  final bool isVisible;

  const _CompactTrackingStrip({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    final isCompact = DesignCanvasScope.of(context).deviceClass == DeviceClass.compact;
    if (!isCompact || !isVisible) return const SizedBox.shrink();

    return BlocBuilder<TraceCubit, TraceState>(
      builder: (context, traceState) => TrackingStrip(
        changedNames: traceState.changedNames,
        changedValues: traceState.changedValues,
      ),
    );
  }
}
