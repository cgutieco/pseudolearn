import '../../domain/model/agent/agent_turn_step.dart';
import '../../domain/model/agent/model_item.dart';
import '../../domain/model/agent/model_outcome.dart';
import '../../domain/ports/agent_model_gateway.dart';
import '../../domain/ports/identifier_generator.dart';
import 'agent_loop_outcome.dart';
import 'agent_turn.dart';
import 'confirmation_policy.dart';
import 'prompt_assembler.dart';
import 'tool_registry.dart';
import 'tools/tool_arguments.dart';
import 'tools/tool_execution.dart';

final class AgentLoop {
  static const int maxModelCalls = 14;

  final AgentModelGateway _gateway;
  final ToolRegistry _registry;
  final PromptAssembler _assembler;
  final IdentifierGenerator _identifiers;
  final ConfirmationPolicy _policy;

  const AgentLoop({
    required AgentModelGateway gateway,
    required ToolRegistry registry,
    required PromptAssembler assembler,
    required IdentifierGenerator identifiers,
    ConfirmationPolicy policy = const ConfirmationPolicy(),
  }) : _gateway = gateway,
       _registry = registry,
       _assembler = assembler,
       _identifiers = identifiers,
       _policy = policy;

  AgentTurn start(List<ModelItem> conversation, String text) => AgentTurn(
    turnId: _identifiers.generate(),
    history: [...conversation, UserTextItem(text)],
  );

  Future<AgentLoopOutcome> advance(AgentTurn start) async {
    var turn = start;
    while (true) {
      if (turn.pendingCalls.isNotEmpty) {
        final next = await _resolveNextCall(turn);
        if (next is AgentLoopOutcome) return next;
        turn = next as AgentTurn;
        continue;
      }
      if (turn.modelCalls >= maxModelCalls) return AgentExhausted(turn);
      final request = await _assembler.build(turn.history, _registry.definitions);
      final outcome = await _gateway.respond(
        request,
        requestId: _identifiers.generate(),
        turnId: turn.turnId,
      );
      if (outcome is ModelFailed) return AgentFailed(turn, outcome.failure);
      final answered = outcome as ModelAnswered;
      turn = turn.answered(answered.items, answered.balance);
      if (turn.pendingCalls.isEmpty) return AgentAnswered(turn);
    }
  }

  AgentTurn decide(AgentTurn turn, {required bool approved}) {
    final call = turn.pendingCalls.first;
    if (approved) return turn.approving(call.callId);
    return _finish(
      turn,
      call,
      ToolExecution.failed('declined_by_person', detail: 'Do not retry this action in this turn.'),
      status: AgentStepStatus.declined,
      declinedTool: call.name,
    );
  }

  Future<Object> _resolveNextCall(AgentTurn turn) async {
    final call = turn.pendingCalls.first;
    final tool = _registry.named(call.name);
    final arguments = decodeToolArguments(call.arguments);
    if (tool == null) return _finish(turn, call, ToolExecution.failed('unknown_tool'));
    if (arguments == null) return _finish(turn, call, ToolExecution.failed('invalid_arguments'));
    if (turn.declinedTools.contains(call.name)) {
      return _finish(turn, call, ToolExecution.failed('declined_by_person'), status: AgentStepStatus.declined);
    }
    final approved = turn.approvedCallId == call.callId;
    if (!approved && _policy.requiresConfirmation(tool, arguments)) {
      return AgentAwaitsConfirmation(turn, call: call, tool: tool.definition, arguments: arguments);
    }
    return _finish(turn, call, await _execute(tool.run, arguments));
  }

  Future<ToolExecution> _execute(
    Future<ToolExecution> Function(ToolArguments arguments) run,
    ToolArguments arguments,
  ) async {
    try {
      return await run(arguments);
    } catch (_) {
      return ToolExecution.failed('tool_failed');
    }
  }

  AgentTurn _finish(
    AgentTurn turn,
    ToolCallItem call,
    ToolExecution execution, {
    AgentStepStatus? status,
    String? declinedTool,
  }) {
    final definition = _registry.named(call.name)?.definition;
    final step = AgentTurnStep(
      toolName: call.name,
      label: definition?.stepLabel ?? 'agentStepUnknown',
      status: status ?? (execution.succeeded ? AgentStepStatus.succeeded : AgentStepStatus.failed),
      summary: execution.summary,
    );
    return turn.resolved(
      ToolOutputItem(callId: call.callId, output: execution.encoded()),
      step,
      declinedTool: declinedTool,
    );
  }
}
