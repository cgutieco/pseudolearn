import 'block_position.dart';
import 'execution_focus.dart';
import 'watch_row.dart';

final class ExecutionStep {
  final int stepNumber;
  final ExecutionFocus? focus;
  final int focusRevision;
  final BlockPosition blockPosition;
  final String scopeName;
  final int scopeDepth;
  final List<WatchRow> variables;
  final bool isFinished;
  final bool isHalted;
  final String? haltReason;
  final bool isStepLimitReached;
  final bool isAwaitingInput;
  final String? inputPrompt;
  final String? expectedInputType;

  const ExecutionStep({
    required this.stepNumber,
    required this.scopeName,
    required this.scopeDepth,
    this.focus,
    this.focusRevision = 0,
    this.blockPosition = const BlockPosition.outermost(),
    this.variables = const [],
    this.isFinished = false,
    this.isHalted = false,
    this.haltReason,
    this.isStepLimitReached = false,
    this.isAwaitingInput = false,
    this.inputPrompt,
    this.expectedInputType,
  });

  const ExecutionStep.unstarted()
      : stepNumber = 0,
        focus = null,
        focusRevision = 0,
        blockPosition = const BlockPosition.outermost(),
        scopeName = 'global',
        scopeDepth = 1,
        variables = const [],
        isFinished = false,
        isHalted = true,
        haltReason = null,
        isStepLimitReached = false,
        isAwaitingInput = false,
        inputPrompt = null,
        expectedInputType = null;

  const ExecutionStep.exhausted()
      : stepNumber = 0,
        focus = null,
        focusRevision = 0,
        blockPosition = const BlockPosition.outermost(),
        scopeName = 'global',
        scopeDepth = 1,
        variables = const [],
        isFinished = true,
        isHalted = false,
        haltReason = null,
        isStepLimitReached = false,
        isAwaitingInput = false,
        inputPrompt = null,
        expectedInputType = null;

  bool get isTerminal => isFinished || isHalted || isStepLimitReached;

  int? get currentLine => focus?.startLine;

  ExecutionStep asStepLimitReached() => ExecutionStep(
        stepNumber: stepNumber,
        focus: focus,
        focusRevision: focusRevision,
        blockPosition: blockPosition,
        scopeName: scopeName,
        scopeDepth: scopeDepth,
        variables: variables,
        isStepLimitReached: true,
      );
}
