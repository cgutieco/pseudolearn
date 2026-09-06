import 'dart:async';

import 'package:bloc/bloc.dart';
import '../execution/execution_state.dart';
import 'trace_rows_projection.dart';
import 'trace_state.dart';

final class TraceCubit extends Cubit<TraceState> {
  late final StreamSubscription<ExecutionState> _subscription;
  final TraceRowsProjection _projection;
  int _runId = 0;
  int _focusRevision = 0;

  TraceCubit({
    required Stream<ExecutionState> executionStates,
    TraceRowsProjection projection = const TraceRowsProjection(),
  })  : _projection = projection,
        super(const TraceState.initial()) {
    _subscription = executionStates.listen(_onExecutionState);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  void _onExecutionState(ExecutionState executionState) {
    if (executionState.runId != _runId) {
      _runId = executionState.runId;
      _focusRevision = 0;
      emit(const TraceState.initial());
    }

    final step = executionState.currentStep;
    if (step.isTerminal) {
      emit(_projection.closed(state, step));
      return;
    }

    final focus = step.focus;
    if (focus == null || step.focusRevision == _focusRevision) return;
    _focusRevision = step.focusRevision;
    emit(_projection.opened(state, step, focus));
  }
}
