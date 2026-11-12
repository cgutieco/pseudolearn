import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/agent_loop.dart';
import 'package:pseudolearn_app/application/agent/agent_loop_outcome.dart';
import 'package:pseudolearn_app/data/agent/fake_agent_model_gateway.dart';
import 'package:pseudolearn_app/domain/model/agent/agent_turn_step.dart';
import 'package:pseudolearn_app/domain/model/agent/model_item.dart';
import 'package:pseudolearn_app/domain/model/agent/model_outcome.dart';
import 'package:pseudolearn_app/domain/model/agent/tool_definition.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import '../../fakes/agent_scripts.dart';

Map<String, Object?> _lastOutput(AgentLoopOutcome outcome) {
  final output = outcome.turn.history.whereType<ToolOutputItem>().last;
  return jsonDecode(output.output) as Map<String, Object?>;
}

void main() {
  test('a plain answer ends the turn after one call', () async {
    final gateway = FakeAgentModelGateway([textReply('Hola')]);
    final loop = testLoop(gateway, const []);
    final outcome = await loop.advance(loop.start(const [], 'hola'));
    expect(outcome, isA<AgentAnswered>());
    expect(outcome.turn.answerText, 'Hola');
    expect(gateway.turnIds, ['turn-1']);
    expect(gateway.requests.single.instructions, contains('SYSTEM-es'));
    expect(gateway.requests.single.instructions, contains('SHEET-es'));
  });

  test('a tool call runs the tool and sends its output back', () async {
    final tool = RecordingTool('check_program');
    final gateway = FakeAgentModelGateway([toolReply('check_program', '{}'), textReply('Listo')]);
    final loop = testLoop(gateway, [tool]);
    final outcome = await loop.advance(loop.start(const [], 'revisa'));
    expect(tool.calls, hasLength(1));
    expect(outcome.turn.steps.single.status, AgentStepStatus.succeeded);
    expect(gateway.requests.last.input.whereType<ToolOutputItem>(), hasLength(1));
    expect(outcome.turn.answerText, 'Listo');
  });

  test('an unknown tool and invalid arguments become error outputs', () async {
    final gateway = FakeAgentModelGateway([
      toolReply('no_such_tool', '{}'),
      toolReply('check_program', 'not json', callId: 'call-2'),
      textReply('ok'),
    ]);
    final loop = testLoop(gateway, [RecordingTool('check_program')]);
    final first = await loop.advance(loop.start(const [], 'x'));
    final outputs = [
      for (final item in first.turn.history.whereType<ToolOutputItem>())
        (jsonDecode(item.output) as Map<String, Object?>)['error'],
    ];
    expect(outputs, ['unknown_tool', 'invalid_arguments']);
    expect(first.turn.steps.map((step) => step.status), everyElement(AgentStepStatus.failed));
  });

  test('a tool that throws reports tool_failed and the turn continues', () async {
    final gateway = FakeAgentModelGateway([toolReply('broken', '{}'), textReply('sigo')]);
    final loop = testLoop(gateway, [RecordingTool('broken', throws: true)]);
    final outcome = await loop.advance(loop.start(const [], 'x'));
    expect(outcome, isA<AgentAnswered>());
    expect(outcome.turn.history.whereType<ToolOutputItem>().single.output, contains('tool_failed'));
  });

  test('the loop stops after fourteen model calls', () async {
    final gateway = FakeAgentModelGateway([
      for (var index = 0; index < 20; index++) toolReply('ping', '{}', callId: 'c$index'),
    ]);
    final loop = testLoop(gateway, [RecordingTool('ping')]);
    final outcome = await loop.advance(loop.start(const [], 'x'));
    expect(outcome, isA<AgentExhausted>());
    expect(gateway.requests, hasLength(AgentLoop.maxModelCalls));
  });

  test('a destructive tool suspends and an approval runs it', () async {
    final tool = RecordingTool('delete_document', risk: ToolRisk.destructive);
    final gateway = FakeAgentModelGateway([toolReply('delete_document', '{"document_id":"d"}'), textReply('Borrado')]);
    final loop = testLoop(gateway, [tool]);
    final suspended = await loop.advance(loop.start(const [], 'borra'));
    expect(suspended, isA<AgentAwaitsConfirmation>());
    expect(tool.calls, isEmpty);
    final resumed = await loop.advance(loop.decide(suspended.turn, approved: true));
    expect(tool.calls, hasLength(1));
    expect(resumed.turn.answerText, 'Borrado');
  });

  test('a declined action is not retried in the same turn', () async {
    final tool = RecordingTool('replace_document_content', confirm: true);
    final gateway = FakeAgentModelGateway([
      toolReply('replace_document_content', '{}'),
      toolReply('replace_document_content', '{}', callId: 'call-2'),
      textReply('Entendido'),
    ]);
    final loop = testLoop(gateway, [tool]);
    final suspended = await loop.advance(loop.start(const [], 'reemplaza'));
    final outcome = await loop.advance(loop.decide(suspended.turn, approved: false));
    expect(outcome, isA<AgentAnswered>());
    expect(tool.calls, isEmpty);
    expect(_lastOutput(outcome)['error'], 'declined_by_person');
    expect(outcome.turn.steps.map((step) => step.status), everyElement(AgentStepStatus.declined));
  });

  test('a credits error in the middle of a turn fails it with that error', () async {
    final gateway = FakeAgentModelGateway([
      toolReply('ping', '{}'),
      const ModelFailed(CreditFailure.creditsExhausted),
    ]);
    final loop = testLoop(gateway, [RecordingTool('ping')]);
    final outcome = await loop.advance(loop.start(const [], 'x'));
    expect(outcome, isA<AgentFailed>());
    expect((outcome as AgentFailed).failure, CreditFailure.creditsExhausted);
    expect(outcome.turn.steps, hasLength(1));
  });

  test('the conversation is carried into the next turn', () async {
    final gateway = FakeAgentModelGateway([textReply('uno'), textReply('dos')]);
    final loop = testLoop(gateway, const []);
    final first = await loop.advance(loop.start(const [], 'a'));
    final second = await loop.advance(loop.start(first.turn.history, 'b'));
    expect(gateway.requests.last.input.whereType<UserTextItem>(), hasLength(2));
    expect(second.turn.answerText, 'dos');
  });
}
