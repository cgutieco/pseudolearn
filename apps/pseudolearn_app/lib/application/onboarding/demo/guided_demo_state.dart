import '../../../domain/model/execution/execution_focus.dart';
import '../../../domain/model/onboarding/guided_demo_surface.dart';
import '../../diagram/diagram_state.dart';
import '../../trace/trace_state.dart';

enum GuidedDemoStatus {
  initial,
  loading,
  ready,
  stepping,
  finished,
  unavailable,
}

final class GuidedDemoState {
  final GuidedDemoStatus status;
  final String code;
  final ExecutionFocus? focus;
  final DiagramState diagram;
  final TraceState trace;
  final List<String> outputLines;
  final GuidedDemoSurface surface;
  final int statementCount;

  const GuidedDemoState({
    this.status = GuidedDemoStatus.initial,
    this.code = '',
    this.focus,
    this.diagram = const DiagramState.initial(),
    this.trace = const TraceState.initial(),
    this.outputLines = const [],
    this.surface = GuidedDemoSurface.diagrams,
    this.statementCount = 0,
  });

  int? get activeLine => focus?.startLine;

  bool get isUnavailable => status == GuidedDemoStatus.unavailable;

  bool get hasProgram => code.trim().isNotEmpty;

  bool get canStep =>
      status == GuidedDemoStatus.ready || status == GuidedDemoStatus.stepping;

  bool get hasStarted => statementCount > 0;

  bool get isFinished => status == GuidedDemoStatus.finished;

  GuidedDemoState copyWith({
    GuidedDemoStatus? status,
    String? code,
    ExecutionFocus? Function()? focus,
    DiagramState? diagram,
    TraceState? trace,
    List<String>? outputLines,
    GuidedDemoSurface? surface,
    int? statementCount,
  }) {
    return GuidedDemoState(
      status: status ?? this.status,
      code: code ?? this.code,
      focus: focus != null ? focus() : this.focus,
      diagram: diagram ?? this.diagram,
      trace: trace ?? this.trace,
      outputLines: outputLines ?? this.outputLines,
      surface: surface ?? this.surface,
      statementCount: statementCount ?? this.statementCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuidedDemoState &&
          status == other.status &&
          code == other.code &&
          focus == other.focus &&
          diagram == other.diagram &&
          trace == other.trace &&
          outputLines.length == other.outputLines.length &&
          surface == other.surface &&
          statementCount == other.statementCount;

  @override
  int get hashCode => Object.hash(
        status,
        code,
        focus,
        diagram,
        trace,
        outputLines.length,
        surface,
        statementCount,
      );
}
