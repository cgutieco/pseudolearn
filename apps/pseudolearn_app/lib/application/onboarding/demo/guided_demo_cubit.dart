import 'package:bloc/bloc.dart';
import '../../../domain/model/diagram/diagram_notation.dart';
import '../../../domain/model/execution/execution_step.dart';
import '../../../domain/model/onboarding/guided_demo_source.dart';
import '../../../domain/model/onboarding/guided_demo_surface.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/program_execution.dart';
import '../../diagram/diagram_projection.dart';
import '../../diagram/diagram_state.dart';
import '../../execution/step_batch_runner.dart';
import '../../execution/step_settlement.dart';
import '../../trace/trace_rows_projection.dart';
import '../../trace/trace_state.dart';
import 'demo_output_lines.dart';
import 'guided_demo_loader.dart';
import 'guided_demo_state.dart';

final class GuidedDemoCubit extends Cubit<GuidedDemoState> {
  final GuidedDemoLoader _loader;
  final ProgramExecution _execution;
  final DiagramProjection _diagrams;
  final TraceRowsProjection _traceRows;
  final DemoOutputLines _outputLines;
  final StepBatchRunner _runner;

  GuidedDemoSource? _source;
  bool _isExecuting = false;
  int _lastRevision = 0;
  int _tracedRevision = 0;

  GuidedDemoCubit({
    required GuidedDemoLoader loader,
    required ProgramExecution execution,
    required DiagramProjection diagrams,
    TraceRowsProjection traceRows = const TraceRowsProjection(),
    DemoOutputLines outputLines = const DemoOutputLines(),
    StepBatchRunner runner = const StepBatchRunner(),
  })  : _loader = loader,
        _execution = execution,
        _diagrams = diagrams,
        _traceRows = traceRows,
        _outputLines = outputLines,
        _runner = runner,
        super(const GuidedDemoState());

  Future<void> start({required UiLanguageId languageId}) async {
    if (state.status == GuidedDemoStatus.loading) return;
    emit(GuidedDemoState(
      status: GuidedDemoStatus.loading,
      surface: state.surface,
    ));
    final source = await _loader.load(languageId);
    if (source == null) {
      emit(GuidedDemoState(
        status: GuidedDemoStatus.unavailable,
        surface: state.surface,
      ));
      return;
    }
    _source = source;
    _prepare(source);
  }

  void restart() {
    final source = _source;
    if (source == null) return;
    _prepare(source);
  }

  Future<void> step() async {
    final source = _source;
    if (source == null || !state.canStep) return;
    if (!_isExecuting && !_beginExecution(source)) return;
    await _runner.runUntilSettled(
      _execution,
      settlement: const StepSettlement.atAnyFocusChange(),
      fromRevision: _lastRevision,
      shouldStop: () => isClosed || !_isExecuting,
      onStep: _absorb,
    );
  }

  void selectSurface(GuidedDemoSurface surface) {
    if (state.surface == surface) return;
    emit(state.copyWith(surface: surface));
  }

  void selectNotation(DiagramNotation notation) {
    if (state.diagram.notation == notation) return;
    emit(state.copyWith(diagram: state.diagram.copyWith(notation: notation)));
  }

  void _prepare(GuidedDemoSource source) {
    _stopExecution();
    final diagram = _diagrams.project(
      previous: const DiagramState.initial(),
      sourceCode: source.code,
      profileId: source.profileId,
      languageId: source.languageId,
    );
    if (!diagram.hasValidAst) {
      emit(GuidedDemoState(
        status: GuidedDemoStatus.unavailable,
        surface: state.surface,
      ));
      return;
    }
    emit(GuidedDemoState(
      status: GuidedDemoStatus.ready,
      code: source.code,
      diagram: diagram,
      surface: state.surface,
    ));
  }

  bool _beginExecution(GuidedDemoSource source) {
    final started = _execution.startExecution(
      sourceCode: source.code,
      profileId: source.profileId,
      languageId: source.languageId,
    );
    _isExecuting = true;
    _lastRevision = started.focusRevision;
    _tracedRevision = 0;
    if (started.isTerminal) {
      _absorb(started);
      return false;
    }
    return true;
  }

  void _stopExecution() {
    if (_isExecuting) _execution.stop();
    _isExecuting = false;
    _lastRevision = 0;
    _tracedRevision = 0;
  }

  void _absorb(ExecutionStep step) {
    final advanced = step.focusRevision != _lastRevision;
    _lastRevision = step.focusRevision;
    final trace = _traceFor(step);
    if (step.isTerminal || step.isAwaitingInput) {
      _isExecuting = false;
      emit(state.copyWith(
        status: GuidedDemoStatus.finished,
        focus: () => null,
        trace: trace,
        outputLines: _outputLines.of(_execution.outputLines),
      ));
      return;
    }
    emit(state.copyWith(
      status: GuidedDemoStatus.stepping,
      focus: () => step.focus,
      diagram: DiagramProjection.followingFocus(state.diagram, step.focus),
      trace: trace,
      outputLines: _outputLines.of(_execution.outputLines),
      statementCount:
          advanced ? state.statementCount + 1 : state.statementCount,
    ));
  }

  TraceState _traceFor(ExecutionStep step) {
    if (step.isTerminal) return _traceRows.closed(state.trace, step);
    final focus = step.focus;
    if (focus == null || step.focusRevision == _tracedRevision) {
      return state.trace;
    }
    _tracedRevision = step.focusRevision;
    return _traceRows.opened(state.trace, step, focus);
  }
}
