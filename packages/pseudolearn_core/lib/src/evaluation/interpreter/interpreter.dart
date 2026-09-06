import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../builtins/builtin_invoker.dart';
import '../environment/call_frame.dart';
import '../environment/reference_binding.dart';
import '../events/environment_snapshot.dart';
import '../events/execution_event.dart';
import '../events/execution_observer.dart';
import '../events/snapshot_builder.dart';
import '../values/random_source.dart';
import '../values/read_value_classifier.dart';
import '../values/value_formatter.dart';
import 'analyzed_program.dart';
import 'arithmetic_task_executor.dart';
import 'array_access_task_executor.dart';
import 'call_task_executor.dart';
import 'conditional_task_executor.dart';
import 'execution_result.dart';
import 'execution_task.dart';
import 'expression_task_executor.dart';
import 'for_loop_task_executor.dart';
import 'input_protocol.dart';
import 'interpreter_frame.dart';
import 'loop_task_executor.dart';
import 'member_access_task_executor.dart';
import 'method_call_task_executor.dart';
import 'oop_task_executor.dart';
import 'runtime_diagnostic_factory.dart';
import 'statement_task_executor.dart';
import 'step_outcome.dart';
import 'task_dispatcher.dart';

final class Interpreter {
  static const int maxCallDepth = 1000;

  final AnalyzedProgram program;
  final ExecutionObserver? observer;
  final RandomSource random;
  final List<InterpreterFrame> frames = [];

  late final BuiltinInvoker builtinInvoker;
  late final ValueFormatter valueFormatter;
  late final ReadValueClassifier readClassifier;
  late final ExpressionTaskExecutor expressions;
  late final ArithmeticTaskExecutor arithmetic;
  late final ArrayAccessTaskExecutor arrayAccess;
  late final StatementTaskExecutor statements;
  late final ConditionalTaskExecutor conditionals;
  late final LoopTaskExecutor loops;
  late final ForLoopTaskExecutor forLoop;
  late final CallTaskExecutor calls;
  late final OopTaskExecutor oop;
  late final MethodCallTaskExecutor methodCalls;
  late final MemberAccessTaskExecutor memberAccess;
  late final InputProtocol inputProtocol;
  late final TaskDispatcher _dispatcher;

  final RuntimeDiagnosticFactory _diagnosticFactory;
  final SnapshotBuilder _snapshotBuilder = const SnapshotBuilder();

  int _nextInstanceId = 1;
  bool _finished = false;
  Diagnostic? _haltedDiagnostic;

  Interpreter._(
      {required this.program, required this.observer, required this.random})
      : _diagnosticFactory = RuntimeDiagnosticFactory(
          (code) => program.profile.severityPolicy[code] ?? Severity.error,
        ) {
    valueFormatter = ValueFormatter(program.profile);
    readClassifier = ReadValueClassifier(program.profile);
    builtinInvoker = BuiltinInvoker(
      random: random,
      formatter: valueFormatter,
      severityFor: severityFor,
      nextInstanceId: () => nextInstanceId,
    );
    expressions = ExpressionTaskExecutor(this);
    arithmetic = ArithmeticTaskExecutor(this);
    arrayAccess = ArrayAccessTaskExecutor(this);
    statements = StatementTaskExecutor(this);
    conditionals = ConditionalTaskExecutor(this);
    loops = LoopTaskExecutor(this);
    forLoop = ForLoopTaskExecutor(this);
    calls = CallTaskExecutor(this);
    oop = OopTaskExecutor(this);
    methodCalls = MethodCallTaskExecutor(this);
    memberAccess = MemberAccessTaskExecutor(this);
    inputProtocol = InputProtocol(this);
    _dispatcher = TaskDispatcher(this);
    frames.add(_buildRootFrame());
  }

  int get nextInstanceId => _nextInstanceId++;

  InterpreterFrame _buildRootFrame() {
    final algo = program.sourceUnit.algorithm;
    final span = algo?.nameSpan ?? Span.zero;
    final frame = InterpreterFrame(
      environment: CallFrame(subroutineName: algo?.name ?? ''),
      hasDeclaredReturnType: false,
      headerSpan: span,
      closingSpan: span,
    );
    if (algo != null) frame.pushBody(algo.body);
    return frame;
  }

  static ExecutionStartResult start({
    required AnalyzedProgram program,
    ExecutionObserver? observer,
    RandomSource? random,
  }) =>
      program.hasErrors
          ? const ExecutionNotExecutable(NotExecutableReason.analysisHasErrors)
          : ExecutionReady(Interpreter._(
              program: program,
              observer: observer,
              random: random ?? SeededRandomSource(),
            ));

  Severity severityFor(DiagnosticCode code) =>
      _diagnosticFactory.severityFor(code);

  Diagnostic diagnostic(DiagnosticCode code, Span span,
          {Map<String, DiagnosticArgument> arguments = const {},
          List<Span> relatedSpans = const []}) =>
      _diagnosticFactory.build(code, span,
          arguments: arguments, relatedSpans: relatedSpans);

  EnvironmentSnapshot? snapshotIfObserved() => observer == null
      ? null
      : _snapshotBuilder.build([for (final frame in frames) frame.environment]);

  void beginAwaitingInput({
    required NodeId designatorId,
    required Span designatorSpan,
    required ReferenceBinding binding,
    required PrimitiveType? expectedType,
  }) =>
      inputProtocol.begin(
        designatorId: designatorId,
        designatorSpan: designatorSpan,
        binding: binding,
        expectedType: expectedType,
      );

  void provideInput(String text) => inputProtocol.provideInput(text);

  StepOutcome step() {
    if (_finished) return const StepFinished();
    final halted = _haltedDiagnostic;
    if (halted != null) return StepHalted(halted);
    final pending = inputProtocol.pending;
    if (pending != null) {
      return StepAwaitingInput(
          designatorId: pending.designatorId,
          expectedType: pending.expectedType);
    }

    final completion = _tryCompleteCurrentFrame();
    if (completion != null) return completion;

    final frame = frames.last;
    final task = frame.popTask();
    final events = <ExecutionEvent>[];
    final failure = _dispatch(task, frame, events);
    if (failure != null) return _halt(failure);

    for (final event in events) {
      observer?.onEvent(event);
    }
    final justAwaited = inputProtocol.pending;
    if (justAwaited != null) {
      return StepAwaitingInput(
        designatorId: justAwaited.designatorId,
        expectedType: justAwaited.expectedType,
      );
    }
    return StepAdvanced(events);
  }

  StepOutcome? _tryCompleteCurrentFrame() {
    final frame = frames.last;
    final done = frame.isReturning || !frame.hasPendingTasks;
    if (!done) return null;

    if (frames.length == 1) {
      _finished = true;
      const event = ExecutionFinishedEvent();
      observer?.onEvent(event);
      return const StepAdvanced([event]);
    }

    if (frame.hasDeclaredReturnType && !frame.isReturning) {
      final diag = diagnostic(
        DiagnosticCode.subroutineEndedWithoutReturn,
        frame.closingSpan,
        arguments: {'lexeme': LexemeDiagnosticArgument(frame.environment.subroutineName)},
        relatedSpans: [frame.headerSpan],
      );
      return _halt(diag);
    }

    frames.removeLast();
    final caller = frames.last;
    final exitEvent = SubroutineExitedEvent(
      subroutineName: frame.environment.subroutineName,
      snapshot: snapshotIfObserved(),
    );
    observer?.onEvent(exitEvent);
    final returnValue = frame.returnValue;
    if (frame.pushValueOnReturn && returnValue != null) {
      caller.pushOperand(returnValue);
    }
    return StepAdvanced([exitEvent]);
  }

  StepOutcome _halt(Diagnostic diag) {
    _haltedDiagnostic = diag;
    observer?.onEvent(DiagnosticEmittedEvent(diag));
    final event = ExecutionHaltedEvent(diag);
    observer?.onEvent(event);
    return StepHalted(diag);
  }

  Diagnostic? _dispatch(
    ExecutionTask task,
    InterpreterFrame frame,
    List<ExecutionEvent> events,
  ) =>
      _dispatcher.dispatch(task, frame, events);
}
