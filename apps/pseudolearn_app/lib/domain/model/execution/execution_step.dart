import 'block_position.dart';
import 'effect_wait.dart';
import 'execution_focus.dart';
import 'execution_task_context.dart';
import 'input_wait.dart';
import 'watch_row.dart';

final class ExecutionStep {
  final int stepNumber;
  final int eventIndex;
  final int taskId;
  final List<ExecutionTaskContext> taskContexts;
  final ExecutionFocus? focus;
  final int focusRevision;
  final BlockPosition blockPosition;
  final String scopeName;
  final int scopeDepth;
  final List<WatchRow> variables;
  final bool isFinished;
  final bool isHalted;
  final bool isCancelled;
  final String? haltReason;
  final bool isStepLimitReached;
  final bool isUiSafetyLimitReached;
  final bool isAwaitingInput;
  final InputWait? inputWait;
  final String? inputPrompt;
  final String? expectedInputType;
  final EffectWait? pendingEffect;

  const ExecutionStep({
    required this.stepNumber,
    required this.scopeName,
    required this.scopeDepth,
    this.eventIndex = -1,
    this.taskId = 0,
    this.taskContexts = const [],
    this.focus,
    this.focusRevision = 0,
    this.blockPosition = const BlockPosition.outermost(),
    this.variables = const [],
    this.isFinished = false,
    this.isHalted = false,
    this.isCancelled = false,
    this.haltReason,
    this.isStepLimitReached = false,
    this.isUiSafetyLimitReached = false,
    this.isAwaitingInput = false,
    this.inputWait,
    this.inputPrompt,
    this.expectedInputType,
    this.pendingEffect,
  });

  const ExecutionStep.unstarted()
    : stepNumber = 0,
      eventIndex = -1,
      taskId = 0,
      taskContexts = const [],
      focus = null,
      focusRevision = 0,
      blockPosition = const BlockPosition.outermost(),
      scopeName = 'global',
      scopeDepth = 1,
      variables = const [],
      isFinished = false,
      isHalted = true,
      isCancelled = false,
      haltReason = null,
      isStepLimitReached = false,
      isUiSafetyLimitReached = false,
      isAwaitingInput = false,
      inputWait = null,
      inputPrompt = null,
      expectedInputType = null,
      pendingEffect = null;

  const ExecutionStep.exhausted()
    : stepNumber = 0,
      eventIndex = -1,
      taskId = 0,
      taskContexts = const [],
      focus = null,
      focusRevision = 0,
      blockPosition = const BlockPosition.outermost(),
      scopeName = 'global',
      scopeDepth = 1,
      variables = const [],
      isFinished = true,
      isHalted = false,
      isCancelled = false,
      haltReason = null,
      isStepLimitReached = false,
      isUiSafetyLimitReached = false,
      isAwaitingInput = false,
      inputWait = null,
      inputPrompt = null,
      expectedInputType = null,
      pendingEffect = null;

  bool get isTerminal =>
      isFinished || isHalted || isCancelled || isStepLimitReached;

  int? get currentLine => focus?.startLine;

  ExecutionStep asStepLimitReached({bool isUiSafetyLimitReached = false}) =>
      ExecutionStep(
        stepNumber: stepNumber,
        eventIndex: eventIndex,
        taskId: taskId,
        taskContexts: taskContexts,
        focus: focus,
        focusRevision: focusRevision,
        blockPosition: blockPosition,
        scopeName: scopeName,
        scopeDepth: scopeDepth,
        variables: variables,
        isCancelled: isCancelled,
        isStepLimitReached: true,
        isUiSafetyLimitReached: isUiSafetyLimitReached,
      );

  bool get isAwaitingEffect => pendingEffect != null;
}
