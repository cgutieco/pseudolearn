import 'package:pseudolearn_app/application/agent/agent_loop.dart';
import 'package:pseudolearn_app/application/agent/prompt_assembler.dart';
import 'package:pseudolearn_app/application/agent/screen_context_board.dart';
import 'package:pseudolearn_app/application/agent/tool_registry.dart';
import 'package:pseudolearn_app/application/agent/tools/agent_tool.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_arguments.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_execution.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_schema.dart';
import 'package:pseudolearn_app/data/agent/fake_agent_model_gateway.dart';
import 'package:pseudolearn_app/domain/model/agent/model_item.dart';
import 'package:pseudolearn_app/domain/model/agent/model_outcome.dart';
import 'package:pseudolearn_app/domain/model/agent/screen_context_snapshot.dart';
import 'package:pseudolearn_app/domain/model/agent/tool_definition.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'fake_agent_ports.dart';
import 'fake_identifier_generator.dart';

ModelOutcome textReply(String text, {int remaining = 30}) => ModelAnswered(
  items: [AssistantTextItem(text)],
  balance: CreditBalance(remaining: remaining, allowance: 40, topUp: 0),
);

ModelOutcome toolReply(String name, String arguments, {String callId = 'call-1', int remaining = 35}) =>
    ModelAnswered(
      items: [ToolCallItem(callId: callId, name: name, arguments: arguments)],
      balance: CreditBalance(remaining: remaining, allowance: 40, topUp: 0),
    );

final class RecordingTool implements AgentTool {
  final String name;
  final ToolRisk risk;
  final bool confirm;
  final bool throws;
  final List<ToolArguments> calls = [];

  RecordingTool(this.name, {this.risk = ToolRisk.read, this.confirm = false, this.throws = false});

  @override
  ToolDefinition get definition => ToolDefinition(
    name: name,
    description: 'Test tool',
    parameters: objectSchema(const {}),
    risk: risk,
    stepLabel: 'step-$name',
  );

  @override
  bool needsConfirmation(ToolArguments arguments) => confirm;

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    calls.add(arguments);
    if (throws) throw StateError('boom');
    return ToolExecution.done({'ran': name}, summary: name);
  }
}

AgentLoop testLoop(FakeAgentModelGateway gateway, List<AgentTool> tools, {ScreenContextBoard? board}) =>
    AgentLoop(
      gateway: gateway,
      registry: ToolRegistry(tools),
      identifiers: FakeIdentifierGenerator(['turn-1', 'r1', 'r2', 'r3', 'r4', 'r5', 'r6']),
      assembler: PromptAssembler(
        prompts: const FakeAgentPromptSource(),
        knowledge: const FakeKnowledgeIndex(),
        screen: board ?? ScreenContextBoard(),
        ambient: () => AmbientContext(
          interfaceLanguage: 'es',
          defaultProfile: 'classicSpanish',
          date: DateTime.utc(2026, 11, 8),
          platform: 'test',
        ),
      ),
    );
