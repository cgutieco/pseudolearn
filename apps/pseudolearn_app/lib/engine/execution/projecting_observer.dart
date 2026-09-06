import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/execution/execution_branch.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/watch_row.dart';
import '../mapping/compound_statement_index.dart';
import '../mapping/node_span_index.dart';
import '../mapping/span_projection.dart';
import '../mapping/unit_membership_index.dart';
import 'statement_stack.dart';
import 'watch_row_projection.dart';

final class ProjectingObserver implements ExecutionObserver {
  final NodeSpanIndex _spans;
  final CompoundStatementIndex _compounds;
  final UnitMembershipIndex _units;
  final StatementStack _stack = StatementStack();

  final List<OutputLine> outputLines = [];
  final List<WatchRow> currentVariables = [];
  ExecutionFocus? currentFocus;
  int focusRevision = 0;
  String currentScope = 'global';
  int currentScopeDepth = 1;
  bool isFinished = false;
  bool isHalted = false;
  bool isAwaitingInput = false;
  NodeId? inputDesignatorId;
  PrimitiveType? expectedInputType;

  ProjectingObserver({
    NodeSpanIndex spans = const NodeSpanIndex.empty(),
    CompoundStatementIndex compounds = const CompoundStatementIndex.empty(),
    UnitMembershipIndex units = const UnitMembershipIndex.empty(),
  })  : _spans = spans,
        _compounds = compounds,
        _units = units;

  @override
  void onEvent(ExecutionEvent event) {
    switch (event) {
      case StatementEnteredEvent(:final statementId, :final snapshot):
        _enterStatement(statementId);
        _updateEnvironment(snapshot);
      case StatementExitedEvent(:final snapshot):
        _updateEnvironment(snapshot);
        _stack.exit();
      case DecisionEvaluatedEvent():
        _focusOnDecision(event);
        _updateEnvironment(event.snapshot);
      case OutputProducedEvent(:final text):
        _onOutputProduced(text);
      case InputRequestedEvent():
        _onInputRequested(event);
      case InputAcceptedEvent():
        _onInputAccepted(event);
      case SubroutineEnteredEvent():
        _onSubroutineEntered(event);
      case SubroutineExitedEvent():
        _onSubroutineExited(event);
      case DiagnosticEmittedEvent():
        break;
      case ExecutionFinishedEvent():
        isFinished = true;
      case ExecutionHaltedEvent():
        isHalted = true;
    }
  }

  bool _hasOpenLine = false;

  void _onOutputProduced(String text) {
    if (text.isEmpty) return;
    final parts = text.split('\n');
    for (var i = 0; i < parts.length; i++) {
      _appendOutputPart(parts[i], i == parts.length - 1, i > 0);
    }
  }

  void _appendOutputPart(String part, bool isLastPart, bool isAfterNewline) {
    if (isAfterNewline) {
      _hasOpenLine = false;
    }
    if (part.isEmpty && isLastPart) return;

    if (_hasOpenLine &&
        outputLines.isNotEmpty &&
        outputLines.last.kind == OutputLineKind.programOutput) {
      outputLines[outputLines.length - 1] = OutputLine(
        text: outputLines.last.text + part,
        kind: OutputLineKind.programOutput,
      );
    } else {
      outputLines.add(
        OutputLine(text: part, kind: OutputLineKind.programOutput),
      );
    }
    _hasOpenLine = isLastPart;
  }

  void _onInputRequested(InputRequestedEvent event) {
    isAwaitingInput = true;
    inputDesignatorId = event.designatorId;
    expectedInputType = event.expectedType;
  }

  void _onInputAccepted(InputAcceptedEvent event) {
    isAwaitingInput = false;
    _hasOpenLine = false;
    outputLines.add(
      OutputLine(text: event.rawText, kind: OutputLineKind.userInputEcho),
    );
  }

  void _onSubroutineEntered(SubroutineEnteredEvent event) {
    currentScope = event.subroutineName;
    _stack.enterFrame();
    _focusOnSpan(event.callSpan, ExecutionFocusKind.subroutineEntered);
    _updateEnvironment(event.snapshot);
  }

  void _onSubroutineExited(SubroutineExitedEvent event) {
    _markBoundary(ExecutionFocusKind.subroutineExited);
    _stack.exitFrame();
    _updateEnvironment(event.snapshot);
  }

  Span? spanOf(NodeId nodeId) => _spans.spanOf(nodeId);

  ExecutionStep toExecutionStep(
    int stepNumber, {
    String? haltReason,
    String? inputPrompt,
  }) {
    return ExecutionStep(
      stepNumber: stepNumber,
      focus: currentFocus,
      focusRevision: focusRevision,
      blockPosition: _stack.position,
      scopeName: currentScope,
      scopeDepth: currentScopeDepth,
      variables: List.unmodifiable(currentVariables),
      isFinished: isFinished,
      isHalted: isHalted,
      haltReason: haltReason,
      isAwaitingInput: isAwaitingInput,
      inputPrompt: inputPrompt,
      expectedInputType: expectedInputType?.name,
    );
  }

  void _enterStatement(NodeId nodeId) {
    _stack.enter(ProgramNodeId(nodeId.value));
    if (_compounds.contains(nodeId)) return;
    _focusOn(nodeId, ExecutionFocusKind.statement);
  }

  void _focusOnDecision(DecisionEvaluatedEvent event) {
    currentFocus = ExecutionFocus(
      nodeId: ProgramNodeId(event.decisionId.value),
      range: SpanProjection.toSourceRange(event.decisionSpan),
      kind: ExecutionFocusKind.decision,
      branch: _toBranch(event),
      unitId: _units.unitIdOf(event.decisionId),
    );
    focusRevision++;
  }

  ExecutionBranch _toBranch(DecisionEvaluatedEvent event) => ExecutionBranch(
        kind: switch (event.branch) {
          DecisionBranch.affirmative => ExecutionBranchKind.affirmative,
          DecisionBranch.negative => ExecutionBranchKind.negative,
          DecisionBranch.selectedCase => ExecutionBranchKind.selectedCase,
          DecisionBranch.defaultCase => ExecutionBranchKind.defaultCase,
        },
        caseIndex: event.caseIndex,
      );

  void _focusOn(NodeId nodeId, ExecutionFocusKind kind) {
    final span = _spans.spanOf(nodeId);
    if (span == null) return;
    currentFocus = ExecutionFocus(
      nodeId: ProgramNodeId(nodeId.value),
      range: SpanProjection.toSourceRange(span),
      kind: kind,
      unitId: _units.unitIdOf(nodeId),
    );
    focusRevision++;
  }

  void _focusOnSpan(Span span, ExecutionFocusKind kind) {
    final previous = currentFocus;
    currentFocus = ExecutionFocus(
      nodeId: previous?.nodeId ?? const ProgramNodeId(0),
      range: SpanProjection.toSourceRange(span),
      kind: kind,
      unitId: previous?.unitId,
    );
    focusRevision++;
  }

  void _markBoundary(ExecutionFocusKind kind) {
    final previous = currentFocus;
    if (previous != null) {
      currentFocus = ExecutionFocus(
        nodeId: previous.nodeId,
        range: previous.range,
        kind: kind,
        unitId: previous.unitId,
      );
    }
    focusRevision++;
  }

  void _updateEnvironment(EnvironmentSnapshot? snapshot) {
    if (snapshot == null) return;
    currentVariables.clear();
    currentScopeDepth = snapshot.frames.length;
    if (snapshot.frames.isNotEmpty) {
      currentScope = snapshot.frames.last.subroutineName;
    }
    for (final frame in snapshot.frames) {
      for (final variable in frame.variables) {
        currentVariables.add(
          WatchRowProjection.toWatchRow(variable, frame.subroutineName),
        );
      }
      if (frame.receiver != null) {
        currentVariables.addAll(
          WatchRowProjection.toReceiverRows(
            frame.receiver!,
            frame.subroutineName,
          ),
        );
      }
    }
  }
}
